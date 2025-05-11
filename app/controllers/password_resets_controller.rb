class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    unless @user
      flash.now[:danger] = 'Email not found'
      render 'new', status: :unprocessable_entity and return
    end

    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:success] = 'Sent an email contains reset page link'
    redirect_to root_path
  end

  def edit
    unless @user
      flash[:danger] = 'user not found'
      redirect_to root_path and return
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_entity and return
    end

    unless @user.update(user_params)
      render 'edit', status: :unprocessable_entity and return
    end

    reset_session
    log_in @user
    flash[:success] = "Password has been reset."
    redirect_to @user
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email].downcase)
  end

  def valid_user
    unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
      redirect_to root_path and return
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired"
      redirect_to new_password_reset_url
    end 
  end
end
