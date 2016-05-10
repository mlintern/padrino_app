#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

require 'compendium-api'

# Prep Work - Make sure you have two users, one with admin rights and one without
# user - user, curl
# user2 - user
# admin - admin, curl, translate

anonymous = Nretnil::CompendiumAPI::CompendiumPublic.new('http://localhost:3000')
user = Nretnil::CompendiumAPI::Compendium.new('mweston', 'password', 'http://localhost:3000')
user2 = Nretnil::CompendiumAPI::Compendium.new('maddie', 'password', 'http://localhost:3000')
admin = Nretnil::CompendiumAPI::Compendium.new('administrator', 'password', 'http://localhost:3000')

@options = {
  headers: true,
  label: false,
  details: false
}

@successes = 0
@failures = 0

def divider
  ' - - - - - - - - - - - '
end

def space
  "\n\n"
end

def header(text)
  puts space + divider
  puts text
  puts divider + space
end

def check_result(response, neg = false)
  puts response if @options[:details]
  if response.key?(:error)
    if neg
      @successes += 1
      return true
    else
      @failures += 1
      return false
    end
  elsif neg
    @failures += 1
    puts 'Check permissions for this test'
    return false
  else
    @successes += 1
    return true
  end
end

###
# Get /api
###

header('GET /api') if @options[:headers]

puts "\nGet api root" if @options[:label]
response = anonymous.get('/api')
puts check_result(response)

###
# Get /api/info
###

header('GET /api/info') if @options[:headers]

puts "\nGet api info" if @options[:label]
response = anonymous.get('/api/info')
puts check_result(response)

###
# Get /api/password
###

header('GET /api/password') if @options[:headers]

puts "\nGet Password" if @options[:label]
response = anonymous.get('/api/password')
puts check_result(response)

puts "\nGet Passphrase" if @options[:label]
response = anonymous.get('/api/password/phrase')
puts check_result(response)

###
# Get /api/external_pub
###

header('GET /api/external_pub') if @options[:headers]

puts "\nGET request to external pub test" if @options[:label]
response = anonymous.get('/api/external_pub')
puts check_result(response)

###
# Post /api/external_pub
###

header('POST /api/external_pub') if @options[:headers]

foodata = { foo: 'bar' }.to_json
data = { content: { id: 8_549_176_320, remove_url: 'http://www.hubot.com/one', title: 'One' } }.to_json
adata = { content: { id: 8_549_176_320, title: 'One' } }.to_json
bdata = { content: { id: 8_549_176_320, remove_url: 'http://www.hubot.com/one' } }.to_json

puts "\nPOST to external pub test" if @options[:label]
response = anonymous.post('/api/external_pub', data)
puts check_result(response)

puts "\nPOST to external pub test with no remote_url" if @options[:label]
response = anonymous.post('/api/external_pub', adata)
puts check_result(response)

puts "\nPOST to external pub with missing remote_rul and a host" if @options[:label]
response = anonymous.post('/api/external_pub?host=www.icecream.com', adata)
puts check_result(response)

# Negative Test
puts "\nPOST to external pub test with foo data" if @options[:label]
response = anonymous.post('/api/external_pub', foodata)
puts check_result(response, true)

# Negative Test
puts "\nPOST to external pub test with missing title" if @options[:label]
response = anonymous.post('/api/external_pub', bdata)
puts check_result(response, true)

puts "\nPOST to external pub debug test" if @options[:label]
response = anonymous.post('/api/external_pub/debug', data)
puts check_result(response)

puts "\nPOST to external pub debug test iwht missing remote_url and a host" if @options[:label]
response = anonymous.post('/api/external_pub/debug?host=www.icecream.com', adata)
puts check_result(response)

# Negative Test
puts "\nPOST to external pub debug test with foo data" if @options[:label]
response = anonymous.post('/api/external_pub/debug', foodata)
puts check_result(response, true)

# Negative Test
puts "\nPOST to external pub debug test with missing title" if @options[:label]
response = anonymous.post('/api/external_pub/debug', bdata)
puts check_result(response, true)

###
# Get /api/fakedata
###

header('GET /api/fakedata') if @options[:headers]

query = { name: 'name', lastname: 'surname', username: 'username', dob: 'date', description: 'sentence', count: 100, email: 'email' }

puts "\nGet Fake Data with no options" if @options[:label]
response = anonymous.get('/api/fakedata')
puts check_result(response)

puts "\nGet Fake Data with options " if @options[:label]
response = anonymous.get('/api/fakedata', query)
puts check_result(response)

###
# Post /api/fakedata
###

header('POST /api/fakedata') if @options[:headers]

data = { name: 'name', lastname: 'surname', username: 'username', dob: 'date', description: 'sentence', count: 100, email: 'email' }

puts "\nGet Fake Data with no options" if @options[:label]
response = anonymous.post('/api/fakedata', data.to_json)
puts check_result(response)

###
# GET /api/accounts/me
###

header('GET /api/accounts/me') if @options[:headers]

puts "\nGet own account info as user" if @options[:label]
response = user.get('/api/accounts/me')
user_id = response['id']
puts check_result(response)

puts "\nGet own account info and admin" if @options[:label]
response = admin.get('/api/accounts/me')
admin_id = response['id']
puts check_result(response)

###
# GET /api/accounts
###

header('GET /api/accounts') if @options[:headers]

# Negative Test
puts "\nGet all accounts as user - Should 403" if @options[:label]
response = user.get('/api/accounts')
puts check_result(response, true)

puts "\nGet all accounts info as admin" if @options[:label]
response = admin.get('/api/accounts')
puts check_result(response)

###
# GET /api/accounts/:id
###

header('GET /api/accounts/:id') if @options[:headers]

puts "\nGet own account by id as user" if @options[:label]
response = user.get('/api/accounts/' + user_id.to_s)
puts check_result(response)

# Negative Test
puts "\nGet different account by id as user - Should 404" if @options[:label]
response = user.get('/api/accounts/' + admin_id.to_s)
puts check_result(response, true)

puts "\nGet own account by id as admin" if @options[:label]
response = admin.get('/api/accounts/' + admin_id.to_s)
puts check_result(response)

puts "\nGet different account by id as admin" if @options[:label]
response = admin.get('/api/accounts/' + user_id.to_s)
puts check_result(response)

###
# POST /api/accounts
###

header('POST /api/accounts') if @options[:headers]

data = { username: Time.now.utc.to_i, email: 'test@test.com', password: 'password', password_confirmation: 'password' }.to_json

# Negative Test
puts "\nCreate account as user - Should 403" if @options[:label]
response = user.post('/api/accounts', data)
puts check_result(response, true)

puts "\nCreate account as admin" if @options[:label]
response = admin.post('/api/accounts', data)
puts check_result(response)

new_user_id = response['id']
new_username = response['username']

# Negative Test
puts "\nCreate Duplicate account as admin - Should 400" if @options[:label]
response = admin.post('/api/accounts', data)
puts check_result(response, true)

###
# PUT /api/accounts/:id
###

header('PUT /api/accounts/:id') if @options[:headers]

updata = { name: 'API', surname: 'Tester' }.to_json

# Negative Test
puts "\nUpdate new user account as user - Should 403" if @options[:label]
response = user.put('/api/accounts/' + new_user_id.to_s, updata)
puts check_result(response, true)

newuser = Nretnil::CompendiumAPI::Compendium.new(new_username, 'password', 'http://localhost:3000')

puts "\nUpdate new user account as self" if @options[:label]
response = newuser.put('/api/accounts/' + new_user_id.to_s, updata)
puts check_result(response)

updata2 = { username: 'api_tester', role: ['user'] }.to_json

puts "\nUpdate new user account as admin" if @options[:label]
response = admin.put('/api/accounts/' + new_user_id.to_s, updata2)
puts check_result(response)

###
# DELETE /api/accounts/:id
###

header('DELETE /api/accounts/:id') if @options[:headers]

# Negative Test
puts "\nDelete new user account as user - Should 403" if @options[:label]
response = user.delete('/api/accounts/' + new_user_id.to_s)
puts check_result(response, true)

puts "\nDelete new user account as admin" if @options[:label]
response = admin.delete('/api/accounts/' + new_user_id.to_s)
puts check_result(response)

# Negative Test
puts "\nDelete new user account as user - Should 400" if @options[:label]
response = admin.delete('/api/accounts/' + admin_id.to_s)
puts check_result(response, true)

###
# GET /api/todos
###

header('GET /api/todos') if @options[:headers]

puts "\nGet user todos as user" if @options[:label]
response = user.get('/api/todos')
puts check_result(response)

# Negative Test
puts "\nGet admin todos an not user" if @options[:label]
response = admin.get('/api/todos')
puts check_result(response, true)

###
# POST /api/todos
###

header('POST /api/todos') if @options[:headers]

tdata = { title: 'Test Todo' }.to_json
bdata = { titlez: 'Voodoo' }.to_json

puts "\nCreate todo as user" if @options[:label]
response = user.post('/api/todos', tdata)
puts check_result(response)

new_todo_id = response['id']

# Negative Test
puts "\nCreate todo as user with bad data" if @options[:label]
response = user.post('/api/todos', bdata)
puts check_result(response, true)

# Negative Test
puts "\nCreate todo as not user" if @options[:label]
response = admin.post('/api/todos', tdata)
puts check_result(response, true)

###
# PUT /api/todos/:id
###

header('PUT /api/todos/:id') if @options[:headers]

uptdata = { title: 'Edited Test Todo', completed: true }.to_json

# Negative Test
puts "\nUpdate todo as wrong user" if @options[:label]
response = user2.put('/api/todos/' + new_todo_id, uptdata)
puts check_result(response, true)

puts "\nUpdate todo as user" if @options[:label]
response = user.put('/api/todos/' + new_todo_id, uptdata)
puts check_result(response)

# Negative Test
puts "\nUpdate todo as not user" if @options[:label]
response = admin.put('/api/todos/' + new_todo_id, uptdata)
puts check_result(response, true)

###
# Delete /api/todos/:id
###

header('DELETE /api/todos/:id') if @options[:headers]

# Negative Test
puts "\nDelete todo as not user" if @options[:label]
response = admin.delete('/api/todos/' + new_todo_id)
puts check_result(response, true)

# Negative Test
puts "\nDelete todo as wrong user" if @options[:label]
response = user2.delete('/api/todos/' + new_todo_id)
puts check_result(response, true)

puts "\nDelete todo as user" if @options[:label]
response = user.delete('/api/todos/' + new_todo_id)
puts check_result(response)

# Negative Test
puts "\nDelete missing todo as user" if @options[:label]
response = user.delete('/api/todos/' + new_todo_id)
puts check_result(response, true)

header('Results')

puts "#{@successes} Successful Tests and #{@failures} Failed Tests"
