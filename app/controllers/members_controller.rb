class MembersController < ApplicationController
  before_action :authenticate_user!

  # GET /members/invite
  def invite
    set_invitation_view_variables

    # Make a dummy new user.
    @new_user = User.new
  end

  # POST /members/invite
  def invite_create
    # Generate Custom Password and treat user an invited member.
    new_user_params = invite_create_params

    # Create a new user.
    @new_user = User.new(new_user_params)
    @new_user.is_invited_user = true # Mark this user as invited.
    @new_user.password = generate_random_password

    # Make sure that provided company id belongs to the set of companies that are owned by logged in user.
    unless current_user.company_id_valid?(new_user_params[:company_id])
      redirect_to member_invite_path, flash: { failure_notification: "Error 403 Forbidden. You tried to access Company you don't own." }
      return
    end

    if @new_user.save
      # Find Company from database based upon the company id of new user.
      @new_user.send_invitation_email(Company.find(@new_user.company_id), Role.find(@new_user.role_id))
      redirect_to member_invite_path, flash: { success_notification: "We have invited '#{@new_user.first_name}' successfully through an email." }
      return
    end

    set_invitation_view_variables
    render 'members/invite'
  end

  # GET /members/privileges
  def privileges
    # Get logged in User
    @user = current_user

    # Get Company
    @company = Company.where(owner_id: @user.id).first

    # Get all users that belong to company which is owned by current user.
    @members = User.includes(:role).where(company_id: @user.company_id).to_a

    # Remove admin himself.
    @members.delete(@members.detect { |member| member.id == @user.id })

    @roles = Role.all
  end

  # GET /members/privileges/:id
  def privileges_show
    user_id = privileges_show_params[:id]
    render json: { data: { user: User.find(user_id) } }
  end

  # POST /members/privileges/edit
  def privileges_update
    user_id = privileges_update_params[:user_id]
    new_role_id = privileges_update_params[:role_id]

    User.find(user_id).update(role_id: new_role_id)

    render json: { data: { status: true, role_name: Role.find(new_role_id).name } }
  end

  # GET /members
  def index
    # Get members other the logged in user.
    @members = current_tenant.users.includes(:role).where.not(id: current_user.id)
  end

  # GET /members/:id
  def show
    @company = current_tenant
    @member = @company.users.where(id: params[:id]).first
  end

  private

  def set_invitation_view_variables
    # Get logged in User
    @user      = current_user

    # Get companies that are owned by the logged in user.
    @companies = Company.where(owner_id: @user.id)

    # Get Roles
    @roles     = Role.all
  end

  def invite_create_params
    params.require(:user).permit(:first_name, :last_name, :company_id, :role_id, :designation, :email)
  end

  def privileges_show_params
    params.permit(:id)
  end

  def privileges_update_params
    params.permit(:user_id, :role_id)
  end

  def generate_random_password
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    (0...10).map { o[rand(o.length)] }.join
  end
end
