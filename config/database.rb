#!/bin/env ruby
# frozen_string_literal: true

##
# A MySQL connection:
# DataMapper.setup(:default, 'mysql://user:password@localhost/the_database_name')
#
# # A Postgres connection:
# DataMapper.setup(:default, 'postgres://user:password@localhost/the_database_name')
#
# # A Sqlite3 connection
# DataMapper.setup(:default, "sqlite3://" + Padrino.root('db', "development.db"))
#
# # Setup DataMapper using config/database.yml
DataMapper.setup(:default, YAML.load_file(Padrino.root('config/database.yml'))[RACK_ENV])

DataMapper.logger = logger
DataMapper::Property::String.length(255)

# case Padrino.env
#   when :development then DataMapper.setup(:default, "sqlite3://" + Padrino.root('db', "padrino_app_development.db"))
#   when :production  then DataMapper.setup(:default, "sqlite3://" + Padrino.root('db', "padrino_app_production.db"))
#   when :test        then DataMapper.setup(:default, "sqlite3://" + Padrino.root('db', "padrino_app_test.db"))
# end
