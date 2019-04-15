#!/bin/env ruby
# frozen_string_literal: true

# config/workers.rb

Dir[File.expand_path('../app/workers/*.rb', __dir__)].each { |file| require file }
