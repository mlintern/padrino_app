# config/workers.rb

Dir[File.expand_path('../../app/workers/*.rb', __FILE__)].each{|file|require file}