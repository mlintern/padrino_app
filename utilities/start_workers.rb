# encoding: UTF-8
# frozen_string_literal: true

require 'rubygems'

puts 'Spawning Worker'

# Spawn Sidekiq worker inside the current process.
worker_pid = spawn('bundle exec sidekiq -C ./config/sidekiq.yml -r ./config/boot.rb')

Process.wait(worker_pid)
puts 'Worker died.'
Process.kill 'QUIT', Process.pid
