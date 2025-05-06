module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
    session[:session_token] = user.session_token
  end

  def remember(user)
    # user.remember # これをすると、session[:session_token]がDB上で更新され、cookie上のsession[:session_token]と違いが生じる
    cookies.permanent.encrypted[:user_id] = user.id
    if user.remember_token.present?
      cookies.permanent[:remember_token] = user.remember_token
    else
      user.remember
      cookies.permanent[:remember_token] = user.remember_token
    end
  end

  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      @current_user = user if user && session[:session_token] == user.session_token
    elsif cookies.encrypted[:user_id].present?
      user_id = cookies.encrypted[:user_id]
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end

  def current_user?(user)
    user&.== current_user
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
