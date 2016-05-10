#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# Seed add you the ability to populate your db.
# We provide you a basic shell for interaction with the end user.
# So try some code like below:
#
#   name = shell.ask("What's your name?")
#   shell.say name
#

if Account.count == 0

  username  = shell.ask 'Which username do you want use for logging into admin?'
  password  = shell.ask 'Tell me the password to use:'

  shell.say ''

  account = Account.create(username: username, email: 'foo@bar.com', name: 'Foo', surname: 'Bar', password: password, password_confirmation: password, role: ['admin'], last_update: DateTime.now.utc, id: SecureRandom.uuid)

  if account.valid?
    shell.say '================================================================='
    shell.say 'Account has been successfully created, now you can login with:'
    shell.say '================================================================='
    shell.say "   username: #{username}"
    shell.say "   password: #{password}"
    shell.say '================================================================='
  else
    shell.say 'Sorry but some thing went wrong!'
    shell.say ''
    account.errors.full_messages.each { |m| shell.say " - #{m}" }
  end

  shell.say ''

end
