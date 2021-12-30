# basic script to create an admin user for app created by create_rails_app.rb
# usage: bin/rails runner create_admin_user.rb

def prompt(*args)
  print(*args)
  gets.chomp
end

email = prompt("What's your email address? :")
password = prompt("Please enter an account password:")
User.create!(email: email, password: password, role: 'admin')
