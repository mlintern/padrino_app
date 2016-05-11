# encoding: utf-8
# frozen_string_literal: true
require 'bundler/setup'
require 'padrino-core/cli/rake'

PadrinoTasks.use(:database)
PadrinoTasks.use(:datamapper)
PadrinoTasks.init

task :user_setup do
  system 'bundle exec padrino runner tests/lib/user_setup.rb'
end

namespace :selenium do
  task all: :user_setup do
    Dir[File.dirname(__FILE__) + '/tests/selenium/suites/**/*.rb'].each { |file| require file }
  end
end

#
# Rake task for running unit tests
#
namespace :unit_tests do
  task all: :user_setup do
    Dir[File.dirname(__FILE__) + '/tests/api/suites/**/*.rb'].each { |file| require file }
  end
end

#
# Rake tasks for compling sass css
#
namespace :sass do
  task :compile do
    system 'sass sass/assets/stylesheets/_full.scss public/stylesheets/bootstrap-alta.min.css --style compressed'
    system 'cp -r sass/assets/javascripts/bootstrap.min.js public/javascripts/bootstrap.min.js'
    system 'cp -r sass/assets/fonts public/'
    system 'cp -r sass/assets/images/* public/images'
  end

  task :watch do
    system 'sass --watch sass/assets/stylesheets/_full.scss:public/stylesheets/bootstrap-alta.min.css'
  end
end
