class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by_username(params[:login][:username])
    if user && !user.anonymous? && user.authenticate(params[:login][:password])
      if user.confirmed?
        log_in_current_user(user, params[:login][:remember_me])
        redirect_to after_sign_in_path_for(user), :notice => "Logged in!"
      else
        redirect_to new_activation_path, :notice => 'You must confirm your email address.'
      end
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    logged_out_user = log_out_current_user
    redirect_to after_sign_out_path_for(logged_out_user), :notice => "Logged out!"
  end
end
