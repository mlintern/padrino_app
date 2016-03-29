require 'bundler/setup'
require 'padrino-core/cli/rake'

PadrinoTasks.use(:database)
PadrinoTasks.use(:datamapper)
PadrinoTasks.init


namespace :selenium do

  task :all do
    Dir[File.dirname(__FILE__) + "/tests/selenium/suites/**/*.rb"].each { |file| require file }
  end

end

#
# Rake task for running unit tests
#
namespace :unit_tests do
  
  task :all do
    Dir[File.dirname(__FILE__) + "/tests/api/suites/**/*.rb"].each { |file| require file }
  end

end

task :compile_sass do
  system "sass sass/assets/stylesheets/_full.scss public/stylesheets/bootstrap-alta.min.css --style compressed"
  system "cp -r sass/assets/fonts/* public/fonts"
  system "cp -r sass/assets/images/* public/images"
end

task :sass_watch do
  system "sass --watch sass/assets/stylesheets/_full.scss:public/stylesheets/bootstrap-alta.min.css"
end