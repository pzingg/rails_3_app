class ApplicationController < ActionController::Base
  protect_from_forgery
  
  after_filter :store_location

  helper_method :current_user, :member_root_url

  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
    else
      store_and_redirect_to_login
    end
  end
  
  def after_sign_in_path_for(resource)
    session[:previous_urls].last || member_root_url
  end
  
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
  
  def logged_in_as_admin?
    current_user && current_user.admin?
  end
  
  def authenticate_user!
    return true if current_user
    store_and_redirect_to_login
  end
  
  def current_user
    if @current_user.nil? && cookies[:auth_token]
      @current_user = User.find_by_auth_token(cookies[:auth_token]) 
      if @current_user.nil?
        # auth_token no longer exists
        log_out_current_user
      end
    end
    @current_user
  end
  
  def log_in_current_user(user, remember)
    if remember
      cookies.permanent[:auth_token] = user.auth_token
    else
      cookies[:auth_token] = user.auth_token
    end
    Login.log_in_current_session(request.session_options[:id], user_remote_ip, user.id)
  end
  
  def log_out_current_user
    user_logging_out = @current_user
    Login.log_out_current_session(request.session_options[:id], user_remote_ip)
    cookies.delete(:auth_token)
    user_logging_out
  end
  
  def member_root_url
    url_for :controller => 'home', :action => 'show'
  end
  
  def store_and_redirect_to_login
    store_location
    redirect_to login_url, :alert => 'Please log in'
  end
  
  # stack of up to two last unique locations
  def store_location
    session[:previous_urls] ||= []
    session[:previous_urls].prepend request.fullpath if session[:previous_urls].first != request.fullpath
    session[:previous_urls].pop if session[:previous_urls].count > 2
    logger.info("store_location stack: #{session[:previous_urls].inspect}")
  end

  def user_remote_ip
    if request.remote_ip == '127.0.0.1'
      # Hard coded remote address
      '123.45.67.89'
    else
      request.remote_ip
    end
  end  
end
