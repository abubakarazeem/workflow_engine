require 'rails_helper'

RSpec.describe ProjectMembershipsController, type: :controller do
  before(:all) do
    @admin = create(:admin)
    @member = create(:member)
  end

  let(:project) { create(:project) }
  let(:user)    { create(:user) }
  let(:team)    { create(:team) }

  let(:user_membership_params) do
    { project_id: project.id,
      project_member_id: user.id,
      project_member_type: user.class.name }
  end
  let(:team_membership_params) do
    { project_id: project.id,
      project_member_id: team.id,
      project_member_type: team.class.name }
  end

  describe 'GET #index' do
    context 'Without Signing in' do
      it 'should not be able to read memberships' do
        expect do
          get :index, project_id: project.id
        end.to raise_exception(CanCan::AccessDenied)
      end
    end

    context 'With a Signed in user' do
      before(:each) do
        sign_in @member
      end
      it 'should success and render to :index view' do
        get :index, project_id: project.id
        expect(response).to have_http_status(200)
        expect(response).to render_template(:index)
      end

      it 'should assign project to current project' do
        get :index, project_id: project.id
        expect(assigns(:project)).to eq project
      end

      it 'project should have no members' do
        get :index, project_id: project.id
        expect(assigns(:users)).to eq []
      end
      it 'project should have no teams' do
        get :index, project_id: project.id
        expect(assigns(:teams)).to eq []
      end
    end
  end

  describe 'POST #create' do
    context 'Without Signing in' do
      it 'should not be able to create membership' do
        expect do
          xhr :post, :create, user_membership_params
        end.to raise_exception(CanCan::AccessDenied)
      end
    end

    context 'For a Member' do
      before(:each) do
        sign_in @member
      end
      it 'should not be able to create membership' do
        expect do
          xhr :post, :create, user_membership_params
        end.to raise_exception(CanCan::AccessDenied)
      end
    end
    context 'For an Administrator' do
      before(:each) do
        sign_in @admin
      end
      context 'with valid attributes' do
        it 'should create a new project-membership for user in the database' do
          expect do
            xhr :post, :create, user_membership_params
          end.to change(ProjectMembership, :count).by(1)
        end

        it 'should create a new project-membership for team in the database' do
          expect do
            xhr :post, :create, team_membership_params
          end.to change(ProjectMembership, :count).by(1)
        end

        it 'should render create template' do
          xhr :post, :create, user_membership_params
          expect(response).to render_template(:create)
        end
      end

      context 'with invalid attributes' do
        let(:user_membership_params) do
          { project_id: nil,
            project_member_id: user.id,
            project_member_type: user.class.name }
        end
        it 'should not create a new project-membership' do
          expect do
            xhr :post, :create, user_membership_params
          end.to_not change(ProjectMembership, :count)
        end
      end

      context 'variable assignments' do
        before :each do
          xhr :post, :create, project_id: project.id,
                              project_member_id: user.id,
                              project_member_type: user.class.name
        end
        it 'should assign project instance variable to current project' do
          expect(assigns(:project)).to eq project
        end

        it 'should assign member instance variable to current user' do
          expect(assigns(:member)).to eq user
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @project_membership = create(:project_membership)
    end

    context 'Without Signing in' do
      it 'should not be able to destroy membership' do
        expect do
          xhr :delete, :destroy, id: @project_membership
        end.to raise_exception(CanCan::AccessDenied)
      end
    end

    context 'For a Member' do
      before(:each) do
        sign_in @member
      end
      it 'should not be able to destroy membership' do
        expect do
          xhr :delete, :destroy, id: @project_membership
        end.to raise_exception(CanCan::AccessDenied)
      end
    end

    context 'For an Administrator' do
      before(:each) do
        sign_in @admin
      end
      it 'should delete the project-membership' do
        expect { xhr :delete, :destroy, id: @project_membership }
          .to change(ProjectMembership, :count).by(-1)
      end

      it 'should render destroy template' do
        xhr :delete, :destroy, id: @project_membership
        expect(response).to render_template(:destroy)
      end
    end
  end

  describe 'GET #search' do
    before(:all) do
      @project = create(:project)
    end

    let(:search_params) do
      { member_type: 'User',
        search_name: 'm',
        project_id: @project.id }
    end
    context 'Without Signing in' do
      it 'should not be able to search members' do
        expect do
          xhr :get, :search, search_params
        end.to raise_exception(CanCan::AccessDenied)
      end
    end

    context 'For a Member' do
      before(:each) do
        sign_in @member
      end
      it 'should not be able to search members' do
        expect do
          xhr :get, :search, search_params
        end.to raise_exception(CanCan::AccessDenied)
      end
    end

    context 'For an Administrator' do
      before(:each) do
        sign_in @admin
      end

      it 'should be able to search members' do
        expect do
          xhr :get, :search, search_params
        end.to_not raise_exception(CanCan::AccessDenied)
      end

      it 'should return member names and ids' do
        xhr :get, :search, search_params
        member_names_ids = ProjectMembership.search_for_membership(
          search_params[:member_type],
          search_params[:search_name],
          @project
        )
        expect(assigns(:members)).to eq member_names_ids
      end
    end
  end
end

RSpec.describe ProjectMembershipsController, type: :routing do
  describe 'routing' do
    it 'should route to #index' do
      expect(get: '/projects/1/project_memberships').to route_to(
        controller: 'project_memberships',
        action: 'index',
        project_id: '1'
      )
    end
    it 'should route to #create' do
      expect(post: '/project_memberships').to route_to(
        controller: 'project_memberships',
        action: 'create'
      )
    end
    it 'should route to #destroy' do
      expect(delete: '/project_memberships/1').to route_to(
        controller: 'project_memberships',
        action: 'destroy',
        id: '1'
      )
    end
    it 'should route to #search' do
      expect(get: '/project_memberships/search').to route_to(
        controller: 'project_memberships',
        action: 'search'
      )
    end
  end
end
