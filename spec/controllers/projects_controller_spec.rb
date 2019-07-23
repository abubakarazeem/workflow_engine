require 'rails_helper'
require 'spec_helper'

RSpec.describe ProjectsController, type: :controller do

  let(:project_attr) { FactoryGirl.attributes_for(:project) }
  let(:invalid_project_attr) { FactoryGirl.attributes_for(:invalid_project) }
  let(:project) { FactoryGirl.create(:project) }

  describe 'GET #index' do
    it 'should populate an array of projects' do
      get :index
      expect(assigns(:projects)).to eq([project])
    end

    it 'should success and render to :index view' do
      get :index
      expect(response).to have_http_status(200)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'should assign the requested project to @project' do
      get :show, id: project
      expect(assigns(:project)).to eq(project)
    end
    it "should assign the requested project's issues to @issues" do
      get :show, id: project
      expect(assigns(:issues)).to eq(project.issues)
    end
    it 'should success and render to the :show template' do
      get :show, id: project
      expect(response).to have_http_status(200)
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    it 'should render the :new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'should save the new project in the database' do
        expect { post :create, project: project_attr }
          .to change(Project, :count).by(1)
        expect(flash[:notice]).to eq 'Successfully created a project.'
      end
      it "should redirect to that new project's page" do
        post :create, project: project_attr
        expect(response).to redirect_to Project.last
      end
    end

    context 'with invalid attributes' do
      it 'should not save the new project in the database' do
        expect do
          post :create, project: invalid_project_attr
        end.to_not change(Project, :count)
      end
      it 'should re-render the :new template' do
        post :create, project: invalid_project_attr
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT update' do
    let(:edit_title) { 'Edit Test Proj' }
    let(:edit_description) { 'I am editing this test project.' }

    context 'valid attributes' do
      it 'should locate the requested @project' do
        put :update, id: project, project: project_attr
        expect(assigns(:project)).to eq(project)
      end

      it "should change the @project's attributes" do
        put :update, id: project, project: FactoryGirl.attributes_for(
          :project, title: edit_title,
                    description: edit_description
        )
        project.reload
        expect(project.title).to eq(edit_title)
        expect(project.description).to eq(edit_description)
      end

      it 'should redirect to the updated project' do
        put :update, id: project, project: project_attr
        expect(response).to redirect_to @project
      end
    end

    context 'invalid attributes' do
      it 'should locate the requested @project' do
        put :update, id: project,
                     project: invalid_project_attr
        expect(assigns(:project)).to eq(project)
      end

      it "should not change @project's attributes" do
        put :update, id: project,
                     project: FactoryGirl.attributes_for(
                       :project, title: edit_title, description: nil
                     )
        project.reload
        expect(project.title).to_not eq(edit_title)
      end

      it 'should re-render the edit method' do
        put :update, id: project, project: FactoryGirl.attributes_for(
          :invalid_project
        )
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE destroy' do
    before :each do
      @project = FactoryGirl.create(:project)
    end
    it 'should delete the contact' do
      expect { delete :destroy, id: @project }
        .to change(Project, :count).by(-1)
    end

    it 'should redirect to contacts#index' do
      delete :destroy, id: @project
      expect(response).to redirect_to projects_url
    end
  end
end

RSpec.describe ProjectsController, type: :routing do
  describe 'routing' do
    it 'should route to #index' do
      expect(get: '/projects').to route_to('projects#index')
    end

    it 'should route to #show' do
      expect(get: '/projects/1').to route_to('projects#show', id: '1')
    end

    it 'should route to #new' do
      expect(get: '/projects/new').to route_to('projects#new')
    end

    it 'should route to #update via PUT' do
      expect(put: '/projects/1').to route_to('projects#update', id: '1')
    end

    it 'should route to #update via PATCH' do
      expect(patch: '/projects/1').to route_to('projects#update', id: '1')
    end
  end
end