describe UserNotifierMailer, type: :mailer do

  context '#user_create' do
    let(:user) { FactoryGirl.create(:operator).user }
    let(:token) { Faker::Internet.password(8) }
    let(:mailer) { UserNotifierMailer.user_create(user, token) }

    subject { mailer }

    it { expect(mailer.to).to include(user.email) }
    it { expect(mailer.subject).to include('Welcome to Moove') }


    it 'should send an email' do
      expect { mailer.deliver! }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should contain user's first name" do
      expect(mailer.body.encoded).to match(/Dear #{user.f_name}/)
    end

    context '= employee' do
      let(:user) { FactoryGirl.create(:employee).user }

      it 'should have app download link', pending_refactoring: true do
        expect(mailer.body.encoded).to match(/Download the MOOVE app <a href=".*".*>.*<\/a>/)
      end
    end

    context '= driver' do
      let(:user) { FactoryGirl.create(:driver).user }

      it 'should have app download link', pending_refactoring: true do
        expect(mailer.body.encoded).to match(/Download the MOOVE app <a href=".*".*>.*<\/a>/)
      end
    end

    context '= other user' do
      let(:user) { FactoryGirl.create(:employer).user }

      it 'should contain token in password reset link' do
        expect(mailer.body.encoded).to match(/<a.*href=".*#{token}.*">Reset Password<\/a>/)
      end

    end

  end
end