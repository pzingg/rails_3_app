class UserMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def activation(user)
    @user = user
    mail :to => user.email, :subject => "Confirm Your Account"
  end
  
  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Reset Your Password"
  end
end
