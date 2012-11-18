# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# User.find([User::ANONYMOUS_USER_ID, User::SUPER_USER_ID]).each { |u| u.destroy }

# Create an anonymous user
anon_user  = User.new(username: 'anonymous', first_name: 'Anonymous', last_name: 'User', email: 'anon@example.com')
anon_user.password = 'guest'
anon_user.password_confirmation = 'guest'
anon_user.roles  = [ 'Guest' ]
anon_user.status = [ 'Active' ]
anon_user.id = User::ANONYMOUS_USER_ID
anon_user.save!

# Create a super user
super_user = User.new(username: 'administrator', first_name: 'Admin', last_name: 'User', email: 'admin@example.com')
super_user.password = 'secret'
super_user.password_confirmation = 'secret'
super_user.roles  = [ 'Admin' ]
super_user.status = [ 'Active' ]
super_user.id = User::SUPER_USER_ID
super_user.save!