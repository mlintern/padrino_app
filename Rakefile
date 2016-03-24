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