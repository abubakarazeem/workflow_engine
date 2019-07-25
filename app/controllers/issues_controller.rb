# Issues Controller
class IssuesController < ApplicationController
  # Shows all issues page by page
  def index
    @issues = Issue.order(:project_id).page(params[:page])
    respond_to do |format|
      format.html
      format.js { render 'filter.js.erb' }
    end
  end

  # Filters rows of issues
  def filter
    @issues = Issue.where(search_params).page(params[:page])
    @issues = @issues.where('title like ?', "%#{params[:search_filter]}%")
    respond_to do |format|
      format.js
    end
  end

  # Adds watcher in IssueWatcher table
  def add_watcher
    @issue = Issue.find(params[:issue_id])
    begin
      current_user.watching_issues << @issue
    rescue ActiveRecord::RecordNotUnique
      flash[:error] = 'Already added!'
    end
    respond_to do |format|
      format.js { render 'toggle_watcher_button.js.erb' }
    end
  end

  # Removes watcher from IssueWatcher table
  def remove_watcher
    @issue = Issue.find(params[:issue_id])
    @issue_watcher = @issue.issue_watchers.find_by(watcher_id: current_user,
                                                   watcher_type: 'User')
    @issue_watcher.destroy
    respond_to do |format|
      format.js { render 'toggle_watcher_button.js.erb' }
    end
  end

  # Searches members to add to watchers list
  def search_watcher
    @user = User.find_by(email: params[:watcher_email])
    respond_to do |format|
      format.js
    end
  end

  # Creates instance of new issue
  def new
    @issue = Issue.new
  end

  # Shows details of particular issue
  def show
    @issue = Issue.find(params[:id])
  end

  # Shows edit page particular issue
  def edit
    @issue = Issue.find(params[:id])
  end

  # Updates particular issue
  def update
    @issue = Issue.find(params[:id])
    if @issue.update(issue_params)
      flash[:update_issue] = 'Issue Updated successfully!'
      redirect_to @issue
    else
      render 'edit'
    end
  end

  # Creates new issue
  def create
    @issue = Issue.new(issue_params)
    @issue.company_id, @issue.project_id = 1
    @issue.creator_id = 2
    @issue.parent_issue_id = 1
    if @issue.save
      flash[:save_issue] = 'Issue Created successfully!'
      redirect_to @issue # redirect to show page
    else
      render 'new'
    end
  end

  # Destroys particular issue
  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy
    flash[:destroy_issue] = 'Issue Deleted successfully'
    redirect_to issues_path
  end

  private

  # Permits columns of issue while adding to database
  def issue_params
    params.require(:issue).permit(:title, :description, :start_date, :due_date,
                                  :progress, :priority, :company_id,
                                  :creator_id, :assignee_id,
                                  :parent_issue_id, :project_id,
                                  :issue_state_id, :issue_type_id)
  end

  # Permits columns of issue that are not blank for search
  def search_params
    params.
      # Optionally, whitelist your search parameters with permit
      permit(:project_id, :assignee_id, :issue_state_id, :issue_type_id).
      # Delete any passed params that are nil or empty string
      delete_if { |_key, value| value.blank? }
  end

  # Permits columns of issue_watcher while adding to database
  def issue_watcher_params
    params.require(:issue_watcher).permit(:watcher_id, :watcher_type, :issue_id)
  end
end
