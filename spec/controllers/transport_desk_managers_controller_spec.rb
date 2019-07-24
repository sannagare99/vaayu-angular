describe TransportDeskManagersController, type: :controller do
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

        tr_d_manager_1 = FactoryGirl.create(:transport_desk_manager)
        tr_d_manager_2 = FactoryGirl.create(:transport_desk_manager)

        tr_d_manager_1_user = tr_d_manager_1.user
        tr_d_manager_2_user = tr_d_manager_2.user

        get :index, { format: :json }

        is_expected.to eq({
                              'aaData' => [{
                                               'DT_RowId' => tr_d_manager_2_user.entity.id,
                                               'id' => tr_d_manager_2_user.entity.id,
                                               'name' => tr_d_manager_2_user.f_name.to_s + ' ' +tr_d_manager_2_user.m_name.to_s+ ' ' + tr_d_manager_2_user.l_name.to_s,
                                               'f_name' => tr_d_manager_2_user.f_name.to_s,
                                               'm_name' => tr_d_manager_2_user.m_name.to_s,
                                               'l_name' => tr_d_manager_2_user.l_name.to_s,
                                               'email' => tr_d_manager_2_user.email,
                                               'phone' => tr_d_manager_2_user.phone,
                                               'status' => tr_d_manager_2_user.status.to_s.split("_").join(" ").capitalize,
                                               'entity_attributes' => {
                                                   'id' => tr_d_manager_2_user.entity.id,
                                                   'company' => tr_d_manager_2_user.entity.employee_company&.name,
                                               }
                                           },
                                           {
                                               'DT_RowId' => tr_d_manager_1_user.entity.id,
                                               'id' => tr_d_manager_1_user.entity.id,
                                               'name' => tr_d_manager_1_user.f_name.to_s + ' ' +tr_d_manager_1_user.m_name.to_s+ ' ' + tr_d_manager_1_user.l_name.to_s,
                                               'f_name' => tr_d_manager_1_user.f_name.to_s,
                                               'm_name' => tr_d_manager_1_user.m_name.to_s,
                                               'l_name' => tr_d_manager_1_user.l_name.to_s,
                                               'email' => tr_d_manager_1_user.email,
                                               'phone' => tr_d_manager_1_user.phone,
                                               'status' => tr_d_manager_1_user.status.to_s.split("_").join(" ").capitalize,
                                               'entity_attributes' => {
                                                   'id' => tr_d_manager_1_user.entity.id,
                                                   'company' => tr_d_manager_1_user.entity.employee_company&.name,
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
        tr_d_manager_1 = FactoryGirl.create(:transport_desk_manager)
        tr_d_manager_2 = FactoryGirl.create(:transport_desk_manager)

        tr_d_manager_1_user = tr_d_manager_1.user
        tr_d_manager_2_user = tr_d_manager_2.user

        get :index, { format: :json }

        is_expected.to eq({
                              'aaData' => [{
                                               'DT_RowId' => tr_d_manager_2_user.entity.id,
                                               'id' => tr_d_manager_2_user.entity.id,
                                               'name' => tr_d_manager_2_user.f_name.to_s + ' ' +tr_d_manager_2_user.m_name.to_s+ ' ' + tr_d_manager_2_user.l_name.to_s,
                                               'f_name' => tr_d_manager_2_user.f_name.to_s,
                                               'm_name' => tr_d_manager_2_user.m_name.to_s,
                                               'l_name' => tr_d_manager_2_user.l_name.to_s,
                                               'email' => tr_d_manager_2_user.email,
                                               'phone' => tr_d_manager_2_user.phone,
                                               'status' => tr_d_manager_2_user.status.to_s.split("_").join(" ").capitalize,
                                               'entity_attributes' => {
                                                   'id' => tr_d_manager_2_user.entity.id,
                                                   'company' => tr_d_manager_2_user.entity.employee_company&.name,
                                               }
                                           },
                                           {
                                               'DT_RowId' => tr_d_manager_1_user.entity.id,
                                               'id' => tr_d_manager_1_user.entity.id,
                                               'name' => tr_d_manager_1_user.f_name.to_s + ' ' +tr_d_manager_1_user.m_name.to_s+ ' ' + tr_d_manager_1_user.l_name.to_s,
                                               'f_name' => tr_d_manager_1_user.f_name.to_s,
                                               'm_name' => tr_d_manager_1_user.m_name.to_s,
                                               'l_name' => tr_d_manager_1_user.l_name.to_s,
                                               'email' => tr_d_manager_1_user.email,
                                               'phone' => tr_d_manager_1_user.phone,
                                               'status' => tr_d_manager_1_user.status.to_s.split("_").join(" ").capitalize,
                                               'entity_attributes' => {
                                                   'id' => tr_d_manager_1_user.entity.id,
                                                   'company' => tr_d_manager_1_user.entity.employee_company&.name,
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
    let(:user) { FactoryGirl.build(:user, entity: FactoryGirl.create(:transport_desk_manager)) }
    let(:params) do
      {
          'user' => {
              'id' => user.id,
              'username' => user.f_name.to_s + ' ' + user.m_name.to_s+ ' ' + user.l_name.to_s,
              'f_name' => user.f_name.to_s,
              'm_name' => user.m_name.to_s,
              'l_name' => user.l_name.to_s,
              'email' => user.email,
              'phone' => user.phone,
              'status' => user.status.to_s.split("_").join(" ").capitalize,
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
    let!(:tr_d_manager) { FactoryGirl.create(:transport_desk_manager) }


    context 'when respond format is html' do
      it 'should update user' do
        post :update, params: { id: tr_d_manager, user: { l_name: 'Test name', entity_attributes: { entity_id: 1 } } }

        expect(flash[:notice]).to eql('Congratulations! Your profile was successfully updated.')
        expect(response).to be_redirect
      end

      it 'should not update user and return error' do
        post :update, params: { id: tr_d_manager, user: { email: 'bad email format', entity_attributes: { entity_id: 1 } } }

        expect(flash[:error]).to eql('Email is not an email')
        expect(response).to be_redirect
      end
    end

    context 'when respond format is json' do
      subject { JSON.parse(response.body) }

      it 'should update user' do
        post :update, { params: { id: tr_d_manager, user: { l_name: 'Test name', entity_attributes: { entity_id: 1 } } },  format: :json }

        expect(flash[:notice]).to eql('Congratulations! Your profile was successfully updated.')
        expect(response).to be_redirect
      end

      it 'should not update user and return error' do
        post :update, { params: { id: tr_d_manager, user: { email: 'bad email format',  entity_attributes: { entity_id: 1 }} },  format: :json }

        expect(flash[:error]).to eql('Email is not an email')
        expect(response).to be_redirect
      end
    end



  end

  describe '#destroy' do
    subject { JSON.parse(response.body) }
    let!(:tr_d_manager) { FactoryGirl.create(:transport_desk_manager) }

    it 'should destroy user' do
      expect{
        delete :destroy, { params: { id: tr_d_manager.id }, format: :json }
      }.to change(User, :count).by(-1)
    end
  end
end