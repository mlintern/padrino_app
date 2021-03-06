# frozen_string_literal: true

require 'bundler/setup'
require 'padrino-core/cli/rake'
require 'fileutils'

PadrinoTasks.use(:database)
PadrinoTasks.use(:datamapper)
PadrinoTasks.init

task :test_setup do
  system 'bundle exec padrino runner tests/lib/test_setup.rb'
end

namespace :selenium do
  task all: :test_setup do
    Dir[File.dirname(__FILE__) + '/tests/selenium/suites/**/*.rb'].each { |file| require file }
  end

  FileList[File.dirname(__FILE__) + '/tests/selenium/suites/**/*.rb'].each do |testfile|
    name = testfile.split('/').last.gsub(/.rb/, '')

    task name.to_sym => :test_setup do
      require testfile
    end
  end
end

#
# Rake task for running unit tests
#
namespace :unit_tests do
  task all: :test_setup do
    Dir[File.dirname(__FILE__) + '/tests/api/suites/**/*.rb'].each { |file| require file }
  end

  FileList[File.dirname(__FILE__) + '/tests/api/suites/**/*.rb'].each do |testfile|
    name = testfile.split('/').last.gsub(/.rb/, '')

    task name.to_sym => :test_setup do
      require testfile
    end
  end
end

#
# Rake tasks for compling sass css
#
namespace :sass do
  task :compile do
    system 'sass sass/assets/stylesheets/_full.scss public/stylesheets/bootstrap-alta.min.css --style compressed'
    # system 'cp -r sass/assets/javascripts/bootstrap.min.js public/javascripts/bootstrap.min.js'
    # system 'cp -r sass/assets/fonts public/'
    # system 'cp -r sass/assets/images/* public/images'
    FileUtils.copy_entry 'sass/assets/fonts', 'public/fonts/'
    FileUtils.copy_entry 'sass/assets/images', 'public/images/'
    FileUtils.copy_entry 'sass/assets/javascripts', 'public/javascripts/'
  end

  task :watch do
    system 'sass --watch sass/assets/stylesheets/_full.scss:public/stylesheets/bootstrap-alta.min.css'
  end
end
