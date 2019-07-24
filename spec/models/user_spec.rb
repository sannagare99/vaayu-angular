require 'rails_helper'

describe User, type: :model do
  before do
    allow_any_instance_of(GoogleMapsService::Client)
        .to receive_message_chain(:geocode, :first)
                .and_return({geometry: { location: {lat: 100, lng: 200} }})

    allow_any_instance_of(GoogleMapsService::Client)
        .to receive(:distance_matrix)
                .and_return({status: 'OK', rows: [elements: [distance: {value: 1234}, status: 'OK']]})

  end
  let!(:user) { FactoryGirl.create(:driver).user }
  subject { user }

  it { should belong_to(:entity).dependent(:destroy) }

  context 'validations' do
    it { should validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username) }
    it { should validate_presence_of(:phone) }
    it { should validate_uniqueness_of(:phone).ignoring_case_sensitivity }


    it { should validate_presence_of(:f_name) }
    it { should validate_presence_of(:l_name) }
  end

  it 'should create proper user when entity passed', pending_refactoring: true do
    new_user = FactoryGirl.create(:user, entity: FactoryGirl.create(:driver))
    expect(new_user.role).to eq('driver')
  end

  context '#login_credentials_cannot_duplicate' do

    it 'should raise error when user has the same username' do
      second_user = FactoryGirl.build(:user, username: user.username, entity: FactoryGirl.create(:driver))

      expect(second_user).not_to be_valid
      expect(second_user.errors.full_messages).to include('Username has already been taken')
    end

    it 'should raise an error when users have the same phone number' do
      second_user = FactoryGirl.build(:user, phone: user.phone, entity: FactoryGirl.create(:employee))

      expect(second_user).not_to be_valid
      expect(second_user.errors.full_messages).to include('Phone has already been taken')
    end

    it 'should raise an error when users have the same email' do
      second_user = FactoryGirl.build(:user, email: user.email, entity: FactoryGirl.create(:operator))

      expect(second_user).not_to be_valid
      expect(second_user.errors.full_messages).to include('Email has already been taken')
    end

    it 'one user cannot have same username and phone', pending_refactoring: true do
      phone = Faker::PhoneNumber.cell_phone
      email = Faker::Internet.email

      user_with_same_phone = FactoryGirl.build(:user, username: phone, phone: phone, entity: FactoryGirl.create(:driver))
      user_with_same_email = FactoryGirl.build(:user, username: email, email: email, entity: FactoryGirl.create(:driver))

      expect(user_with_same_phone).not_to be_valid
      expect(user_with_same_email).not_to be_valid
      # To refactor: strange error messages
      expect(user_with_same_phone.errors.full_messages).to include('Username and phone cannot be same')
      expect(user_with_same_email.errors.full_messages).to include('Username and email cannot be same')
    end

    it 'different users cannot have same username and phone' do
      second_user = FactoryGirl.build(:user, username: user.phone, entity: FactoryGirl.create(:operator))

      expect(second_user).not_to be_valid
      expect(second_user.errors.full_messages).to include('Username has already been taken')
    end

    # This test is redundant, but it marks very important security issue in login_credentials_cannot_duplicate method:
    # where clause uses raw user input such as username or email, so there might be possible sql injection here
    # it needed to be fixed as soon as possible
    it 'should work with any user input data', pending_refactoring: true do
      new_user = FactoryGirl.create(:user, entity: FactoryGirl.create(:driver), phone: "123'3211111")
      expect(new_user).to be_valid
    end
  end

  context "#save_with_notify" do

    [:operator, :employer, :employee, :driver, :guard].each do |role|
      context "the user is #{role}" do
        let!(:user) { FactoryGirl.create(role).user }

        it 'should successfully save and notify user' do
          expect(user.save_with_notify).to be_truthy
        end

        it 'should save password reset token', pending_refactoring: true do
          allow(Devise).to receive_message_chain(:token_generator, :generate).with(user.class, :reset_password_token).and_return(['raw_token', 'enc_token'])
          user.save_with_notify

          expect(user.reset_password_token).to eq('enc_token')
        end

        it 'should increase invites count' do
          expect { user.save_with_notify }.to change { user.invite_count }.by(1)
        end

        it 'should set an username if it was empty' do
          user.username = nil
          user.save_with_notify
          expect(user.username).not_to be_empty
        end

        it 'should not change username if already set' do
          user.update!(username: Faker::Internet.user_name)
          expect { user.save_with_notify }.not_to change { user.username }
        end


        # except driver
        if role != :driver
          it 'should set an email-like username if it was empty' do
            user.username = nil
            user.save_with_notify

            expect(user.username).to eq(user.email.parameterize)
          end
        end

        if role == :driver
          it 'password should be the last 6 licence number symbols' do
            license_number = user.entity.licence_number.last(6)
            user.entity.licence_number = '000999999'
            expect { user.save_with_notify }.to change { user.password }.to('999999')
          end

          it 'should set phone number as username if username blank' do
            user.username = nil
            user.save_with_notify

            expect(user.username).to eq(user.phone)
          end

        end

        if [:operator, :employer].include? role
          it 'should send password reset token in email' do
            allow(Devise).to receive_message_chain(:token_generator, :generate).with(user.class, :reset_password_token).and_return('raw_token', 'enc_token')
            user.save_with_notify

            last_email = ActionMailer::Base.deliveries.last
            expect(last_email.html_part.body.decoded).to match(/<a.*href=".*raw_token.*">Reset Password<\/a>/)
          end

          it 'should not receive an sms' do
            expect(user).not_to receive(:send_sms)
            user.save_with_notify
          end

        end

        if [:operator, :employer, :employee ].include? role
          it 'should send email to user' do
            expect { user.save_with_notify }.to change { ActionMailer::Base.deliveries.count }.by(1)

            last_email = ActionMailer::Base.deliveries.last
            expect(last_email.to).to eq [user.email]
            expect(last_email.subject).to include('Welcome to Moove')
          end

          it "email should contain users's first name" do
            user.save_with_notify
            last_email = ActionMailer::Base.deliveries.last

            expect(last_email.html_part.body.decoded).to include(user.f_name)
          end
        end


        if [:employee, :driver, :guard].include? role
          it 'should receive an sms with trip details' do
            expect(user).to receive(:send_sms)
            user.save_with_notify
          end
        end


        if [:driver, :guard].include? role
          it 'should not receive a welcome email' do
            expect { user.save_with_notify }.not_to change{ ActionMailer::Base.deliveries.count }
          end

        end


      end
    end

  end

  context '#send_sms'
  context '#sms_message'
end
