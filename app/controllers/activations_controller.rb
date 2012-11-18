class ActivationsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by_email(params[:activation][:email])
    user.send_confirmation(:activation) if user
    redirect_to root_url, :notice => 'Email sent with new activation key.'
  end

  def edit
    user = User.find_by_confirmation_token!(params[:id])
    if user.confirmed?
      redirect_to member_root_url, :notice => 'Your account has already been activated.'
    elsif !token_expired_and_redirected(user)
      user.confirm!
      log_in_current_user(user, false)
      redirect_to member_root_url, :notice => 'Your account is now active and you are logged in.'
    end
    # should never get here
  end

  protected
  
  def token_expired_and_redirected(user)
    if user.confirmation_type != 'activation' || user.confirmation_sent_at < 2.hours.ago
      redirect_to new_activation_path, :alert => 'Your activation key has expired.'
      true
    else
      false
    end
  end
end
