describe LineManagersController, type: :controller do
  let(:user) { FactoryGirl.create(:user, entity: FactoryGirl.create(:operator)) }

  before do
    allow(controller).to receive(:authenticate_user!)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe '#index' do
    it { expect(response).to be_success }

    context 'when current_user is admin' do
      before { allow(user).to receive(:admin?).and_return(true) }
      subject { JSON.parse(response.body) }

      it 'should return JSON with empty data' do
        get :index, { format: :json }
        is_expected.to eq({
                              'aaData' => [],
                              'iTotalDisplayRecords' => 0,
                              'iTotalRecords' => 0,
                              'sEcho' => 0
                          })
      end

      it 'should return JSON with data' do
        l_manager_1 = FactoryGirl.create(:line_manager)
        l_manager_2 = FactoryGirl.create(:line_manager)

        get :index, { format: :json }

        is_expected.to eq({
                              'aaData' => [{
                                               'DT_RowId' => l_manager_2.user.entity.id,
                                               'id' => l_manager_2.user.entity.id,
                                               'name' => l_manager_2.user.f_name.to_s + ' ' + l_manager_2.user.m_name.to_s+ ' ' + l_manager_2.user.l_name.to_s,
                                               'f_name' => l_manager_2.user.f_name.to_s,
                                               'm_name' => l_manager_2.user.m_name.to_s,
                                               'l_name' => l_manager_2.user.l_name.to_s,
                                               'email' => l_manager_2.user.email,
                                               'phone' => l_manager_2.user.phone,
                                               'status' => l_manager_2.user.status.to_s.split("_").join(" ").capitalize,
                                               'invite_count' => l_manager_2.user.invite_count,
                                               'entity_attributes' => {
                                                   'id' =>  l_manager_2.user.entity.id,
                                                   'company' => l_manager_2.user.entity.employee_company&.name
                                               }
                                           },
                                           {
                                               'DT_RowId' => l_manager_1.user.entity.id,
                                               'id' => l_manager_1.user.entity.id,
                                               'name' => l_manager_1.user.f_name.to_s + ' ' + l_manager_1.user.m_name.to_s+ ' ' + l_manager_1.user.l_name.to_s,
                                               'f_name' => l_manager_1.user.f_name.to_s,
                                               'm_name' => l_manager_1.user.m_name.to_s,
                                               'l_name' => l_manager_1.user.l_name.to_s,
                                               'email' => l_manager_1.user.email,
                                               'phone' => l_manager_1.user.phone,
                                               'status' => l_manager_1.user.status.to_s.split("_").join(" ").capitalize,
                                               'invite_count' => l_manager_1.user.invite_count,
                                               'entity_attributes' => {
                                                   'id' =>  l_manager_1.user.entity.id,
                                                   'company' => l_manager_1.user.entity.employee_company&.name
                                               }
                                           }],
                              'iTotalDisplayRecords' => 2,
                              'iTotalRecords' => 2,
                              'sEcho' => 0
                          })
      end

    end

    context 'when current_user is employer' do
      before { allow(user).to receive(:employer?).and_return(true) }
      subject { JSON.parse(response.body) }

      it 'should return JSON with empty data' do
        get :index, { format: :json }
        is_expected.to eq({
                              'aaData' => [],
                              'iTotalDisplayRecords' => 0,
                              'iTotalRecords' => 0,
                              'sEcho' => 0
                          })
      end

      it 'should return JSON with data' do
        l_manager_1 = FactoryGirl.create(:line_manager)
        l_manager_2 = FactoryGirl.create(:line_manager)

        get :index, { format: :json }

        is_expected.to eq({
                              'aaData' => [{
                                               'DT_RowId' => l_manager_2.user.entity.id,
                                               'id' => l_manager_2.user.entity.id,
                                               'name' => l_manager_2.user.f_name.to_s + ' ' + l_manager_2.user.m_name.to_s+ ' ' + l_manager_2.user.l_name.to_s,
                                               'f_name' => l_manager_2.user.f_name.to_s,
                                               'm_name' => l_manager_2.user.m_name.to_s,
                                               'l_name' => l_manager_2.user.l_name.to_s,
                                               'email' => l_manager_2.user.email,
                                               'phone' => l_manager_2.user.phone,
                                               'status' => l_manager_2.user.status.to_s.split("_").join(" ").capitalize,
                                               'invite_count' => l_manager_2.user.invite_count,
                                               'entity_attributes' => {
                                                   'id' =>  l_manager_2.user.entity.id,
                                                   'company' => l_manager_2.user.entity.employee_company&.name
                                               }
                                           },
                                           {
                                               'DT_RowId' => l_manager_1.user.entity.id,
                                               'id' => l_manager_1.user.entity.id,
                                               'name' => l_manager_1.user.f_name.to_s + ' ' + l_manager_1.user.m_name.to_s+ ' ' + l_manager_1.user.l_name.to_s,
                                               'f_name' => l_manager_1.user.f_name.to_s,
                                               'm_name' => l_manager_1.user.m_name.to_s,
                                               'l_name' => l_manager_1.user.l_name.to_s,
                                               'email' => l_manager_1.user.email,
                                               'phone' => l_manager_1.user.phone,
                                               'status' => l_manager_1.user.status.to_s.split("_").join(" ").capitalize,
                                               'invite_count' => l_manager_1.user.invite_count,
                                               'entity_attributes' => {
                                                   'id' =>  l_manager_1.user.entity.id,
                                                   'company' => l_manager_1.user.entity.employee_company&.name
                                               }
                                           }],
                              'iTotalDisplayRecords' => 2,
                              'iTotalRecords' => 2,
                              'sEcho' => 0
                          })
      end
    end
  end

  describe '#create' do
    let(:employee_company){ FactoryGirl.create(:employee_company) }
    let(:user) { FactoryGirl.build(:user, entity: FactoryGirl.create(:line_manager)) }
    let(:params) do
      { 'user' => {
          'id' => user.id,
          'f_name' => user.f_name.to_s,
          'm_name' => user.m_name.to_s,
          'l_name' => user.l_name.to_s,
          'email' => user.email,
          'username' => 'Test username',
          'password' => 'password',
          'phone' => user.phone,
          'status' => user.status.to_s.split("_").join(" ").capitalize,
          'invite_count' => user.invite_count,
          'entity_attributes' => {
              'employee_company_id' => employee_company.id
          }
      }
      }
    end

    it 'should create new User' do
      expect{
        post :create, params: params
      }.to change(User, :count).by(1)

      expect(flash[:notice]).to eql('User was successfully created')
      expect(response).to be_redirect
    end

    it 'should not create new User' do
      params['user'].delete('entity_attributes')
      expect{
        post :create, params: params
      }.to_not change(User, :count)

      expect(flash[:error]).to eql('Employee company can\'t be blank')
      expect(response).to be_redirect
    end
  end

  describe '#update' do
    let!(:l_manager) { FactoryGirl.create(:line_manager) }

    context 'when respond format is html' do
      it 'should update user' do
        post :update, params: { id: l_manager, user: { l_name: 'Test name', entity_attributes: { entity_id: 1 } } }

        expect(flash[:notice]).to eql('Congratulations! Your profile was successfully updated.')
        expect(response).to be_redirect
      end

      it 'should not update user and return error' do
        post :update, params: { id: l_manager, user: { email: 'bad email format', entity_attributes: { entity_id: 1 } } }

        expect(flash[:error]).to eql('Email is not an email')
        expect(response).to be_redirect
      end
    end

    context 'when respond format is json' do
      subject { JSON.parse(response.body) }

      it 'should update user' do
        post :update, { params: { id: l_manager, user: { l_name: 'Test name', entity_attributes: { entity_id: 1 } } },  format: :json }

        expect(flash[:notice]).to eql('Congratulations! Your profile was successfully updated.')
        expect(response).to be_redirect
      end

      it 'should not update user and return error' do
        post :update, { params: { id: l_manager, user: { email: 'bad email format', entity_attributes: { entity_id: 1 } } },  format: :json }

        expect(flash[:error]).to eql('Email is not an email')
        expect(response).to be_redirect
      end
    end
  end

  describe '#destroy' do
    subject { JSON.parse(response.body) }
    let!(:l_manager) { FactoryGirl.create(:line_manager) }

    it 'should destroy user' do
      expect{
        delete :destroy, { params: { id: l_manager.id }, format: :json }
      }.to change(User, :count).by(-1)
    end
  end

  describe '#invite' do
    let!(:l_manager) { FactoryGirl.create(:line_manager) }

    it 'should invite user' do
      expect(UserNotifierMailer).to receive_message_chain(:user_create, :deliver_now!)
      get :invite, { params: { id: l_manager.id }, format: :json }

      expect(l_manager.user.invite_count).to eql(1)
    end
  end
end