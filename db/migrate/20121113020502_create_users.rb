class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   :account_number
      t.string   :username
      t.string   :email
      t.string   :first_name
      t.string   :last_name
      t.string   :status
      t.string   :roles
      t.string   :password_digest
      t.string   :auth_token
      t.string   :confirmation_token
      t.string   :confirmation_type
      t.datetime :confirmation_sent_at

      t.timestamps
    end
  end
end
