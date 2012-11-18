class Login < ActiveRecord::Base
  belongs_to :user
  
  attr_accessible :session_id, :user_id, :ip_address, :status, :created_at, :ended_at

  def self.log_in_current_session(session_id, ip_address, user_id)
    login = find(:first, :conditions => ['session_id=? AND status=?', session_id, 'active'])
    if login
      return login if login.user_id == user_id
      login.update_attributes(:ended_at => Time.now, :status => 'logged_out')
    end
    create(:session_id => session_id, :user_id => user_id, :ip_address => ip_address)
  end
  
  def self.log_out_current_session(session_id, ip_address)
    login = find(:first, :conditions => ['session_id=?', session_id])
    if login
      login.update_attributes(:ended_at => Time.now, :status => 'logged_out')
    end
    create(:session_id => session_id, :user_id => User::ANONYMOUS_USER_ID, :ip_address => ip_address)
  end
end
