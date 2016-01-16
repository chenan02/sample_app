class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
   # debugger
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to HELL!!!"
      redirect_to @user
      # redirects to user's prof page
    else
      render 'new'
    end
  end
  
  private
  
    # for security, control what new users control, ie changing params with curl
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
