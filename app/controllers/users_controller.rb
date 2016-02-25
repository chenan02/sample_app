class UsersController < ApplicationController
  # pages that logged_in_user only can visit
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  def new
    @user = User.new
  end
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def show
    @user = User.find(params[:id])
   # debugger
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      # from user_mailer.rb
      @user.send_activation_email
      flash[:info] = "A confirmation link has been sent to your email."
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  def edit
    # already before_action :correct_user
    #@user = User.find(params[:id])
  end
  
  def update
    # already before_action :correct_user
    #@user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else 
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  private
  
    # for security, control what new users control, ie changing params with curl
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    # before filters
    
    # confirms logged-in users
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
    
    # Confirms correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end