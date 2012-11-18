class PasswordResetsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by_email(params[:password_reset][:email])
    user.send_confirmation(:password_reset) if user
    redirect_to root_url, :notice => 'Email sent with password reset instructions.'
  end

  def edit
    @user = User.find_by_confirmation_token!(params[:id])
    if !token_expired_and_redirected(@user)
      # render :edit
    end
  end

  def update
    @user = User.find_by_confirmation_token!(params[:id])
    if !token_expired_and_redirected(@user)
      if @user.update_password!(params[:user][:password], params[:user][:password_confirmation])
        redirect_to member_root_url, :notice => 'Your password has been reset. Please log in.'
      else
        render :edit
      end
    end
  end
  
  protected
  
  def token_expired_and_redirected(user)
    if user.confirmation_type != 'password_reset' || user.confirmation_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => 'Password reset has expired.'
      true
    else
      false
    end
  end
end
