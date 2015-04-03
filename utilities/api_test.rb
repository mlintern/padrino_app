require "compendium-api"

# Prep Work - Make sure you have two users, one with admin rights and one without

user = Nretnil::CompendiumAPI::Compendium.new("mweston", "password", "http://localhost:3000")
admin = Nretnil::CompendiumAPI::Compendium.new("administrator", "password", "http://localhost:3000")

###
# Get /api/accounts/me
###

own_account = user.get("/api/accounts/me")
puts "Get own account info as user"
puts own_account
puts user_id = own_account["id"]

own_account = admin.get("/api/accounts/me")
puts "\nGet own account info and admin"
puts own_account
puts admin_id = own_account["id"]

###
# Get /api/accounts
###

#Negative Test
all_accounts = user.get("/api/accounts")
puts "\nGet all accounts as user - Should 403"
puts all_accounts

puts "\nGet all accounts info as admin"
all_accounts = admin.get("/api/accounts")
puts all_accounts
puts total = all_accounts.length


###
# Get /api/accounts/:id
###

own_account = user.get("/api/accounts/"+user_id.to_s)
puts "\nGet own account by id as user"
puts own_account

#Negative Test
own_account = user.get("/api/accounts/"+admin_id.to_s)
puts "\nGet different account by id as user - Should 404"
puts own_account

own_account = admin.get("/api/accounts/"+admin_id.to_s)
puts "\nGet own account by id as admin"
puts own_account

own_account = admin.get("/api/accounts/"+user_id.to_s)
puts "\nGet different account by id as admin"
puts own_account

###
# Post /api/accounts
###

data = { :username => "new_test_user", :email => "test@test.com", :password => "password", :password_confirmation => "password" }

#Negative Test
all_accounts = user.post("/api/accounts",data)
puts "\nCreate account as user - Should 403"
puts all_accounts

puts "\nCreate account as admin"
all_accounts = admin.post("/api/accounts",data)
puts all_accounts
puts total = all_accounts.length

puts "\nCreate Duplicate account as admin"
all_accounts = admin.post("/api/accounts",data)
puts all_accounts
puts total = all_accounts.length