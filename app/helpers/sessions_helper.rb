module SessionsHelper
  
  # creates temp cookie w/ encrypted userid
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # create remember token & update digest in db
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # returns true if given user is current user
  def current_user?(user)
    user == current_user
  end
  
  # returns current logged-in user
  def current_user
    if (user_id = session[:user_id]) #if session already existing
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id]) #if looking for permanent
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  # @current_user = nil || User.find...
  
  def logged_in?
    !current_user.nil?
  end
  
  # deletes info on cookies
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # redirect to stored location
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
  
  # stored URL
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
end
