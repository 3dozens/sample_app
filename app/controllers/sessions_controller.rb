class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if !user || !user.authenticate(params[:session][:password])
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
      return
    end

    unless user.activated
      flash[:warning] = 'Account not activated'
      redirect_to root_url
      return
    end

    forwarding_url = session[:forwarding_url]
    reset_session
    log_in user
    params[:session][:remember_me] == '1' ? remember(user) : forget(user)
    redirect_to forwarding_url || user
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end
end
