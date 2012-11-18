require 'json_set'

class User < ActiveRecord::Base
  ANONYMOUS_USER_ID = 1
  SUPER_USER_ID = 2
  VALID_STATUS = %w{ Active Unconfirmed PastDue Suspended }.freeze
  VALID_ROLES  = %w{ Admin Guest Trial Regular }.freeze
  
  has_secure_password
  has_many :logins
  has_many :active_logins, :class_name => 'Login', :conditions => { :status => 'active' }
  
  attr_accessible :username, :email, :first_name, :last_name, 
    :account_number, :roles, :status, 
    :password, :password_confirmation

  serialize :roles, JsonSet
  serialize :status, JsonSet
  
  validates :username, :presence => true, :uniqueness => true, :length => 6..16
  validates :email,    :presence => true, :format => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
  validates_each :status do |record, attr, value| JsonSet.validate(record, attr, value, VALID_STATUS) end
  validates_each :roles  do |record, attr, value| JsonSet.validate(record, attr, value, VALID_ROLES) end
  
  before_create :create_missing_defaults
  after_create :account_created
  
  def account_created
    create_unique_attributes
    send_confirmation(:activation)
  end
  
  def admin?
    roles.include? 'Admin'
  end

  def anonymous?
    roles.include? 'Guest'
  end
  
  def confirm!(new_status = 'Active')
    status.delete_if { |e| e == 'Unconfirmed' || e == new_status }
    status << new_status
    confirmation_token = nil
    confirmation_type = nil
    save!
    logger.info "User #{username} confirmed: #{status}"
  end
  
  def confirmed?
    !status.include? 'Unconfirmed'
  end
  
  def create_missing_defaults
    set_default_role_and_status
  end

  def create_unique_attributes
    set_account_number
    set_auth_token
    save!
  end
  
  # message_type is :password_reset or :account_confirmation
  def send_confirmation(message_type)
    set_unique_token(:confirmation_token)
    self.confirmation_type = message_type.to_s
    self.confirmation_sent_at = Time.zone.now
    save!
    UserMailer.send(message_type, self).deliver
  end
  
  def session_count
    active_logins.size
  end

  def set_account_number
    set_unique_token(:account_number, :hex, 8)
  end

  def set_auth_token
    set_unique_token(:auth_token)
  end
  
  def set_default_role_and_status
    self[:roles]  = ['Regular'] if roles.nil? || roles.empty?
    self[:status] = ['Unconfirmed'] if status.nil? || status.empty?
  end

  def set_unique_token(column, method=:urlsafe_base64, n=16)
    begin
      self[column] = SecureRandom.send(method, n)
    end while User.exists?(column => self[column])
  end
  
  def update_password!(pw, pwconfirm)
    password = pw
    password_confirmation = pwconfirm
    confirmation_token = nil
    confirmation_type = nil
    save!
    logger.info "User #{username} password was updated"
  end  
end
