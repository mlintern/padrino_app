# Seed add you the ability to populate your db.
# We provide you a basic shell for interaction with the end user.
# So try some code like below:
#
#   name = shell.ask("What's your name?")
#   shell.say name
#

unless Account.first(:username => "administrator")
  account = Account.create(:username => "administrator", :email => "admin@padrino.com", :name => "Padrino", :surname => "Admin", :password => "password", :password_confirmation => "password", :role => ["admin"], :last_update => DateTime.now )
end

unless Account.first(:username => "mweston")
  account = Account.create(:username => "mweston", :email => "mweston@padrino.com", :name => "Michael", :surname => "Weston", :password => "password", :password_confirmation => "password", :role => ["user"], :last_update => DateTime.now )
end

unless Account.first(:username => "fglenanne")
  account = Account.create(:username => "fglenanne", :email => "fglenanne@padrino.com", :name => "Fiona", :surname => "Glenanne", :password => "password", :password_confirmation => "password", :role => ["user","admin"], :last_update => DateTime.now )
end

unless Account.first(:username => "saxe")
  account = Account.create(:username => "saxe", :email => "saxe@padrino.com", :name => "Sam", :surname => "Axe", :password => "password", :password_confirmation => "password", :role => "", :last_update => DateTime.now )
end

unless Account.first(:username => "jporter")
  account = Account.create(:username => "jporter", :email => "jporter@padrino.com", :name => "Jesse", :surname => "Porter", :password => "password", :password_confirmation => "password", :role => ["other"], :last_update => DateTime.now )
end

if Account.count == 0 || false

  username  = shell.ask "Which username do you want use for logging into admin?"
  password  = shell.ask "Tell me the password to use:"

  shell.say ""

  account = Account.create(:username => username, :email => "foo@bar.com", :name => "Foo", :surname => "Bar", :password => password, :password_confirmation => password, :role => ["admin"], :last_update => DateTime.now)

  if account.valid?
    shell.say "================================================================="
    shell.say "Account has been successfully created, now you can login with:"
    shell.say "================================================================="
    shell.say "   username: #{username}"
    shell.say "   password: #{password}"
    shell.say "================================================================="
  else
    shell.say "Sorry but some thing went wrong!"
    shell.say ""
    account.errors.full_messages.each { |m| shell.say "   - #{m}" }
  end

  shell.say ""

end