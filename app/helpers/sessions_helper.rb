module SessionsHelper
  def login(user)
    remember_token = User.new_remember_token
    cookies[:remember_token] = {
      :value => remember_token,
      :expires => 1.day.from_now
    }
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    begin
      @current_user ||= User.find_by(remember_token: remember_token)
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end
  end

  def current_user?(user)
    user == current_user
  end

  def user_signed_in?
    !current_user.nil?
  end
  
  def authenticate_user!
    unless user_signed_in?
      store_location
      redirect_to signin_url
    end
  end

  def logout
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end
end
