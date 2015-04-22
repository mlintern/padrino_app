# Seed add you the ability to populate your db.
# We provide you a basic shell for interaction with the end user.
# So try some code like below:
#
#   name = shell.ask("What's your name?")
#   shell.say name
#

unless Account.first(:username => "administrator")
  account = Account.create(:username => "administrator", :email => "admin@nretnil.com", :name => "Nretnil", :surname => "Admin", :password => "password", :password_confirmation => "password", :role => ["admin","curl"], :last_update => DateTime.now, :id => SecureRandom.uuid )
end

unless Account.first(:username => "mweston")
  account = Account.create(:username => "mweston", :email => "michael.weston@nretnil.com", :name => "Michael", :surname => "Weston", :password => "password", :password_confirmation => "password", :role => ["user","curl"], :last_update => DateTime.now, :id => SecureRandom.uuid )
  account_property = AccountProperty.create(:id => account.id, :name => "photo", :value => "http://cdn04.cdn.justjared.com/wp-content/uploads/headlines/2009/07/jeffrey-donovan-dui.jpg")
end

unless Account.first(:username => "fglenanne")
  account = Account.create(:username => "fglenanne", :email => "fiona.glenanne@nretnil.com", :name => "Fiona", :surname => "Glenanne", :password => "password", :password_confirmation => "password", :role => ["user","admin"], :last_update => DateTime.now, :id => SecureRandom.uuid )
  account_property = AccountProperty.create(:id => account.id, :name => "photo", :value => "https://s-media-cache-ak0.pinimg.com/736x/6f/33/d6/6f33d6b766401ab77b72b739dc86d3de.jpg")
end

unless Account.first(:username => "saxe")
  account = Account.create(:username => "saxe", :email => "sam.axe@nretnil.com", :name => "Sam", :surname => "Axe", :password => "password", :password_confirmation => "password", :role => "", :last_update => DateTime.now, :id => SecureRandom.uuid )
  account_property = AccountProperty.create(:id => account.id, :name => "photo", :value => "http://boomstickcomics.com/wp-content/uploads/2015/03/showbiz-bruce-campbell-2.jpg")
end

unless Account.first(:username => "jporter")
  account = Account.create(:username => "jporter", :email => "jesse.porter@nretnil.com", :name => "Jesse", :surname => "Porter", :password => "password", :password_confirmation => "password", :role => ["curl"], :last_update => DateTime.now, :id => SecureRandom.uuid )
  account_property = AccountProperty.create(:id => account.id, :name => "photo", :value => "http://www.usanetwork.com/sites/usanetwork/files/styles/person_cover/public/burnnotice_profiles_hero_jesse_0.jpg?itok=cqV92t5A")
end

unless Account.first(:username => "maddie")
  account = Account.create(:username => "maddie", :email => "maddie.weston@nretnil.com", :name => "Madeline", :surname => "Weston", :password => "password", :password_confirmation => "password", :role => ["user"], :last_update => DateTime.now, :id => SecureRandom.uuid )
  account_property = AccountProperty.create(:id => account.id, :name => "photo", :value => "http://xfinity.comcast.net/blogs/tv/files/2010/08/SGlessBN.jpg")
end

unless Account.first(:username => "nweston")
  account = Account.create(:username => "nweston", :email => "nate.weston@nretnil.com", :name => "Nate", :surname => "Weston", :password => "password", :password_confirmation => "password", :role => ["user"], :last_update => DateTime.now, :id => SecureRandom.uuid )
  account_property = AccountProperty.create(:id => account.id, :name => "photo", :value => "http://cdn.images.express.co.uk/img/dynamic/79/590x/452369_1.jpg")
end

unless Account.first(:username => "barry")
  account = Account.create(:username => "barry", :email => "barry@nretnil.com", :name => "Barry", :surname => "", :password => "password", :password_confirmation => "password", :role => ["user"], :last_update => DateTime.now, :id => SecureRandom.uuid )
  account_property = AccountProperty.create(:id => account.id, :name => "photo", :value => "https://media.licdn.com/mpr/mpr/shrinknp_400_400/p/2/000/19f/388/281e185.jpg")
end

if Account.count == 0 || false

  username  = shell.ask "Which username do you want use for logging into admin?"
  password  = shell.ask "Tell me the password to use:"

  shell.say ""

  account = Account.create(:username => username, :email => "foo@bar.com", :name => "Foo", :surname => "Bar", :password => password, :password_confirmation => password, :role => ["admin"], :last_update => DateTime.now, :id => SecureRandom.uuid)

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