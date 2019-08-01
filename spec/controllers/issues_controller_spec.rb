require 'rails_helper'

RSpec.describe IssuesController, type: :controller do
  before(:all) do
    @admin = create(:admin)
    @member = create(:member)
  end
  before(:each) { sign_in @member }
  context 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_success
    end
  end

  context 'GET #filter' do
    it 'returns a success response' do
      xhr :get, :filter, format: :js
      expect(response).to be_success
    end
  end

  context 'Get #new' do
    it 'it render new template' do
      get :new
      expect(response).to be_success
    end
  end

  context 'Get #show' do
    before :all do
      @issue = FactoryGirl.create(:issue)
    end

    it 'returns a success response' do
      get :show, id: @issue
      expect(assigns(:issue)).to eq(@issue)
    end
    it 'should success and render to the :show template' do
      get :show, id: FactoryGirl.create(:issue)
      expect(response).to have_http_status(200)
      expect(response).to render_template :show
    end
  end

  context 'POST #create' do
    context 'with valid attributes' do
      it 'saves the new issue in the database' do
        expect { post :create, issue: FactoryGirl.attributes_for(:issue) }
          .to change(Issue, :count).by(1)
      end

      it "redirects to that new issue's page" do
        post :create, issue: FactoryGirl.attributes_for(:issue)
        expect(response).to redirect_to Issue.last
      end
    end

    context 'with invalid attributes' do
      it 'does not save the new issue in the database' do
        expect { post :create, issue: FactoryGirl.attributes_for(:invalid_issue) }
          .to_not change(Project, :count)
      end
      it 're-renders the :new template' do
        post :create, issue: FactoryGirl.attributes_for(:invalid_issue)
        expect(response).to render_template :new
      end
    end
  end

  describe 'PUT update' do
    context 'Login as Member' do
      before(:each) do
        sign_in @member
      end
      before :all do
        @issue_member_assignee = FactoryGirl.build(:issue)
        @issue_member_assignee.assignee_id = @member.id
        @issue_member_assignee.save
        @issue_member_creator = FactoryGirl.build(:issue)
        @issue_member_creator.creator_id = @member.id
        @issue_member_creator.save
      end

      context 'valid attributes' do
        it 'locates the requested @issue with same assignee_id' do
          put :update, id: @issue_member_assignee, issue: FactoryGirl.attributes_for(:issue_member_assignee)
          expect(assigns(:issue)).to eq(@issue_member_assignee)
        end

        it "changes @issue's attributes with same assignee_id" do
          put :update, id: @issue_member_assignee, issue: FactoryGirl.attributes_for(
            :issue_member_assignee, title: 'This is edited issue',
                                    description: 'Some changed description'
          )
          @issue_member_assignee.reload
          expect(@issue_member_assignee.title).to eq('This is edited issue')
          expect(@issue_member_assignee.description).to eq('Some changed description')
        end

        it 'redirects to the updated issue with same assignee_id' do
          put :update, id: @issue_member_assignee, issue: FactoryGirl.attributes_for(:issue_member_assignee)
          expect(response).to redirect_to @issue
        end

        it 'locates the requested @issue with same creator_id' do
          put :update, id: @issue_member_creator, issue: FactoryGirl.attributes_for(:issue_member_creator)
          expect(assigns(:issue)).to eq(@issue_member_creator)
        end

        it "changes @issue's attributes same creator_id" do
          put :update, id: @issue_member_creator, issue: FactoryGirl.attributes_for(
            :issue_member_creator, title: 'This is edited issue',
                                    description: 'Some changed description'
          )
          @issue_member_creator.reload
          expect(@issue_member_creator.title).to eq('This is edited issue')
          expect(@issue_member_creator.description).to eq('Some changed description')
        end

        it 'redirects to the updated issue same creator_id' do
          put :update, id: @issue_member_creator, issue: FactoryGirl.attributes_for(:issue_member_creator)
          expect(response).to redirect_to @issue
        end
      end

      context 'invalid attributes' do
        it 'locates the requested @issue' do
          put :update,
              id: @issue_member_assignee, issue: FactoryGirl.attributes_for(:invalid_issue)
          expect(assigns(:issue)).to eq(@issue_member_assignee)
        end

        it "does not change @issue's attributes" do
          put :update,
              id: @issue_member_assignee, issue: FactoryGirl.attributes_for(:issue_member_assignee, title: nil)
          @issue_member_assignee.reload
          expect(@issue_member_assignee.title).to eq('This is newly created issue')
        end

        it 're-renders the edit method' do
          put :update, id: @issue_member_assignee, issue: FactoryGirl.attributes_for(
            :invalid_issue
          )
          expect(response).to render_template :edit
        end
      end
    end

    context 'Login as Admin' do
      before(:each) do
        sign_in @admin
      end
      before :all do
        @issue = FactoryGirl.create(:issue)
      end
      context 'valid attributes' do
        it 'locates the requested @issue' do
          put :update, id: @issue, issue: FactoryGirl.attributes_for(:issue)
          expect(assigns(:issue)).to eq(@issue)
        end

        it "changes @issue's attributes" do
          put :update, id: @issue, issue: FactoryGirl.attributes_for(
            :issue, title: 'This is edited issue',
                    description: 'Some changed description'
          )
          @issue.reload
          expect(@issue.title).to eq('This is edited issue')
          expect(@issue.description).to eq('Some changed description')
        end

        it 'redirects to the updated issue' do
          put :update, id: @issue, issue: FactoryGirl.attributes_for(:issue)
          expect(response).to redirect_to @issue
        end
      end

      context 'invalid attributes' do
        it 'locates the requested @issue' do
          put :update,
              id: @issue, issue: FactoryGirl.attributes_for(:invalid_issue)
          expect(assigns(:issue)).to eq(@issue)
        end

        it "does not change @issue's attributes" do
          put :update,
              id: @issue, issue: FactoryGirl.attributes_for(:issue, title: nil)
          @issue.reload
          expect(@issue.title).to eq('This is newly created issue')
        end

        it 're-renders the edit method' do
          put :update, id: @issue, issue: FactoryGirl.attributes_for(
            :invalid_issue
          )
          expect(response).to render_template :edit
        end
      end
    end
  end

  context 'DELETE #destroy' do
    before(:each) do
      sign_in @member
    end

    before :all do
      @issue_member_assignee = FactoryGirl.build(:issue)
      @issue_member_assignee.assignee_id = @member.id
      @issue_member_assignee.save
    end
    # let!(:issue) { create :issue_member_creator }

    it 'should delete issue' do
      delete :destroy, id: @issue_member_assignee.id
      expect(response).to redirect_to issues_url
    end
  end

  context 'Routes testing' do
    it 'routes to #index' do
      expect(get: '/issues').to route_to('issues#index')
    end

    it 'routes to #show' do
      expect(get: '/issues/1').to route_to('issues#show', id: '1')
    end

    it 'routes to #new' do
      expect(get: '/issues/new').to route_to('issues#new')
    end

    it 'routes to #update via PUT' do
      expect(put: '/issues/1').to route_to('issues#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/issues/1').to route_to('issues#update', id: '1')
    end
  end
end