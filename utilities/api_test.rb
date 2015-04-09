require "compendium-api"

# Prep Work - Make sure you have two users, one with admin rights and one without

user = Nretnil::CompendiumAPI::Compendium.new("mweston", "password", "http://localhost:3000")
admin = Nretnil::CompendiumAPI::Compendium.new("administrator", "password", "http://localhost:3000")

@options = {
  :headers =>  true,
  :label => false,
  :details => false
}

@successes = 0
@failures = 0

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

def check_result (response, neg = false)
  puts response if @options[:details]
  if response.key?(:error)
    if neg 
      @successes += 1
      return true
    else
      @failures += 1
      return false
    end
  else
    @successes += 1
    return true
  end
end

###
# GET /api/accounts/me
###

header("GET /api/accounts/me") if @options[:headers]

puts "Get own account info as user" if @options[:label] 
response = user.get("/api/accounts/me")
user_id = response["id"]
puts check_result(response)

puts "\nGet own account info and admin" if @options[:label] 
response = admin.get("/api/accounts/me")
admin_id = response["id"]
puts check_result(response)

###
# GET /api/accounts
###

header("GET /api/accounts") if @options[:headers]

#Negative Test
puts "\nGet all accounts as user - Should 403" if @options[:label]
response = user.get("/api/accounts")
puts check_result(response,true)

puts "\nGet all accounts info as admin" if @options[:label]
response = admin.get("/api/accounts")
puts check_result(response)


###
# GET /api/accounts/:id
###

header("GET /api/accounts/:id") if @options[:headers]

puts "\nGet own account by id as user" if @options[:label]
response = user.get("/api/accounts/"+user_id.to_s)
puts check_result(response)

#Negative Test
puts "\nGet different account by id as user - Should 404" if @options[:label]
response = user.get("/api/accounts/"+admin_id.to_s)
puts check_result(response,true)

puts "\nGet own account by id as admin" if @options[:label]
response = admin.get("/api/accounts/"+admin_id.to_s)
puts check_result(response)

puts "\nGet different account by id as admin" if @options[:label]
response = admin.get("/api/accounts/"+user_id.to_s)
puts check_result(response)

###
# POST /api/accounts
###

header("POST /api/accounts") if @options[:headers]

data = { :username => Time.now.to_i, :email => "test@test.com", :password => "password", :password_confirmation => "password" }.to_json

#Negative Test
puts "\nCreate account as user - Should 403" if @options[:label]
response = user.post("/api/accounts",data)
puts check_result(response,true)

puts "\nCreate account as admin" if @options[:label]
response = admin.post("/api/accounts",data)
puts check_result(response)

new_user_id = response["id"]
new_username = response["username"]

#Negative Test
puts "\nCreate Duplicate account as admin - Should 400" if @options[:label]
response = admin.post("/api/accounts",data)
puts check_result(response,true)


###
# PUT /api/accounts/:id
###

header("PUT /api/accounts/:id") if @options[:headers]

updata = { :name => "API", :surname => "Tester" }.to_json

#Negative Test
puts "\nUpdate new user account as user - Should 403" if @options[:label]
response = user.put("/api/accounts/"+new_user_id.to_s,updata)
puts check_result(response,true)

newuser = Nretnil::CompendiumAPI::Compendium.new(new_username, "password", "http://localhost:3000")

puts "\nUpdate new user account as self" if @options[:label]
response = newuser.put("/api/accounts/"+new_user_id.to_s,updata)
puts check_result(response)

updata2 = { :username => "api_tester", :role => ["user"] }.to_json

puts "\nUpdate new user account as admin" if @options[:label]
response = admin.put("/api/accounts/"+new_user_id.to_s,updata2)
puts check_result(response)


###
# DELETE /api/accounts/:id
###

header("DELETE /api/accounts/:id") if @options[:headers]

#Negative Test
puts "\nDelete new user account as user - Should 403" if @options[:label]
response = user.delete("/api/accounts/"+new_user_id.to_s)
puts check_result(response,true)

puts "\nDelete new user account as admin" if @options[:label]
response = admin.delete("/api/accounts/"+new_user_id.to_s)
puts check_result(response)

#Negative Test
puts "\nDelete new user account as user - Should 400" if @options[:label]
response = admin.delete("/api/accounts/"+admin_id.to_s)
puts check_result(response,true)

header("Results")

puts "#{@successes} Successful Tests and #{@failures} Failed Tests"
