require "compendium-api"

# Prep Work - Make sure you have two users, one with admin rights and one without

user = Nretnil::CompendiumAPI::Compendium.new("mweston", "password", "http://localhost:3000")
admin = Nretnil::CompendiumAPI::Compendium.new("administrator", "password", "http://localhost:3000")

label = false

def divider
  " - - - - - - - - - - - "
end

def space
  space = "\n\n"
end

def header (text)
  puts space+divider
  puts text
  puts divider+space
end

def check_result (response)
  # puts response
  if response.key?(:error)
    return false
  else
    return true
  end
end

###
# GET /api/accounts/me
###

header("GET /api/accounts/me")

puts "Get own account info as user" if label 
response = user.get("/api/accounts/me")
user_id = response["id"]
puts check_result(response)

puts "\nGet own account info and admin" if label 
response = admin.get("/api/accounts/me")
admin_id = response["id"]
puts check_result(response)

###
# GET /api/accounts
###

header("GET /api/accounts")

#Negative Test
puts "\nGet all accounts as user - Should 403" if label
response = user.get("/api/accounts")
puts !check_result(response)

puts "\nGet all accounts info as admin" if label
response = admin.get("/api/accounts")
puts check_result(response)


###
# GET /api/accounts/:id
###

header("GET /api/accounts/:id")

puts "\nGet own account by id as user" if label
response = user.get("/api/accounts/"+user_id.to_s)
puts check_result(response)

#Negative Test
puts "\nGet different account by id as user - Should 404" if label
response = user.get("/api/accounts/"+admin_id.to_s)
puts !check_result(response)

puts "\nGet own account by id as admin" if label
response = admin.get("/api/accounts/"+admin_id.to_s)
puts check_result(response)

puts "\nGet different account by id as admin" if label
response = admin.get("/api/accounts/"+user_id.to_s)
puts check_result(response)

###
# POST /api/accounts
###

header("POST /api/accounts")

data = { :username => Time.now.to_i, :email => "test@test.com", :password => "password", :password_confirmation => "password" }.to_json

#Negative Test
puts "\nCreate account as user - Should 403" if label
response = user.post("/api/accounts",data)
puts !check_result(response)

puts "\nCreate account as admin" if label
response = admin.post("/api/accounts",data)
puts check_result(response)

new_user_id = response["id"]
new_username = response["username"]

#Negative Test
puts "\nCreate Duplicate account as admin - Should 400" if label
response = admin.post("/api/accounts",data)
puts !check_result(response)


###
# PUT /api/accounts/:id
###

header("PUT /api/accounts/:id")

updata = { :name => "API", :surname => "Tester" }.to_json

#Negative Test
puts "\nUpdate new user account as user - Should 403" if label
response = user.put("/api/accounts/"+new_user_id.to_s,updata)
puts !check_result(response)

newuser = Nretnil::CompendiumAPI::Compendium.new(new_username, "password", "http://localhost:3000")

puts "\nUpdate new user account as self" if label
response = newuser.put("/api/accounts/"+new_user_id.to_s,updata)
puts check_result(response)

updata2 = { :username => "api_tester", :role => ["user"] }.to_json

puts "\nUpdate new user account as admin" if label
response = admin.put("/api/accounts/"+new_user_id.to_s,updata2)
puts check_result(response)


###
# DELETE /api/accounts/:id
###

header("DELETE /api/accounts/:id")

#Negative Test
puts "\nDelete new user account as user - Should 403" if label
response = user.delete("/api/accounts/"+new_user_id.to_s)
puts !check_result(response)

puts "\nDelete new user account as admin" if label
response = admin.delete("/api/accounts/"+new_user_id.to_s)
puts check_result(response)

#Negative Test
puts "\nDelete new user account as user - Should 400" if label
response = admin.delete("/api/accounts/"+admin_id.to_s)
puts !check_result(response)