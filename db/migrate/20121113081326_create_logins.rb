class CreateLogins < ActiveRecord::Migration
  def change
    create_table :logins do |t|
      t.string   :session_id
      t.integer  :user_id
      t.string   :ip_address
      t.string   :status, :null => false, :default => 'active'
      t.datetime :created_at
      t.datetime :ended_at
    end
  end
end
