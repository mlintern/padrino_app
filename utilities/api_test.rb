require "compendium-api"

# Prep Work - Make sure you have two users, one with admin rights and one without

user = Nretnil::CompendiumAPI::Compendium.new("mweston", "password", "http://localhost:3000")
admin = Nretnil::CompendiumAPI::Compendium.new("administrator", "password", "http://localhost:3000")

###
# GET /api/accounts/me
###

puts "Get own account info as user"
own_account = user.get("/api/accounts/me")
puts own_account
puts user_id = own_account["id"]

puts "\nGet own account info and admin"
own_account = admin.get("/api/accounts/me")
puts own_account
puts admin_id = own_account["id"]

###
# GET /api/accounts
###

#Negative Test
puts "\nGet all accounts as user - Should 403"
all_accounts = user.get("/api/accounts")
puts all_accounts

puts "\nGet all accounts info as admin"
all_accounts = admin.get("/api/accounts")
puts all_accounts
puts total = all_accounts.length


###
# GET /api/accounts/:id
###

puts "\nGet own account by id as user"
own_account = user.get("/api/accounts/"+user_id.to_s)
puts own_account

#Negative Test
puts "\nGet different account by id as user - Should 404"
own_account = user.get("/api/accounts/"+admin_id.to_s)
puts own_account

puts "\nGet own account by id as admin"
own_account = admin.get("/api/accounts/"+admin_id.to_s)
puts own_account

puts "\nGet different account by id as admin"
own_account = admin.get("/api/accounts/"+user_id.to_s)
puts own_account

###
# POST /api/accounts
###

data = { :username => Time.now.to_i, :email => "test@test.com", :password => "password", :password_confirmation => "password" }.to_json

#Negative Test
puts "\nCreate account as user - Should 403"
new_user = user.post("/api/accounts",data)
puts new_user

puts "\nCreate account as admin"
new_user = admin.post("/api/accounts",data)
puts new_user

new_user_id = new_user["id"]
new_username = new_user["username"]

#Negative Test
puts "\nCreate Duplicate account as admin - Should 400"
new_user = admin.post("/api/accounts",data)
puts new_user


###
# PUT /api/accounts/:id
###

updata = { :name => "API", :surname => "Tester" }.to_json

#Negative Test
puts "\nUpdate new user account as user - Should 403"
update_user = user.put("/api/accounts/"+new_user_id.to_s,updata)
puts update_user

newuser = Nretnil::CompendiumAPI::Compendium.new(new_username, "password", "http://localhost:3000")

puts "\nUpdate new user account as self"
update_user = newuser.put("/api/accounts/"+new_user_id.to_s,updata)
puts update_user

updata2 = { :username => "api_tester", :role => ["user"] }.to_json

puts "\nUpdate new user account as admin"
update_user = admin.put("/api/accounts/"+new_user_id.to_s,updata2)
puts update_user


###
# DELETE /api/accounts/:id
###

#Negative Test
puts "\nDelete new user account as user - Should 403"
delete_user = user.delete("/api/accounts/"+new_user_id.to_s)
puts delete_user

puts "\nDelete new user account as admin"
delete_user = admin.delete("/api/accounts/"+new_user_id.to_s)
puts delete_user

#Negative Test
puts "\nDelete new user account as user - Should 400"
delete_self = admin.delete("/api/accounts/"+admin_id.to_s)
puts delete_self
