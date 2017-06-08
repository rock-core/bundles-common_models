require "bundler/gem_tasks"
require 'yard'
require 'yard/rake/yardoc_task'

task :default

YARD::Rake::YardocTask.new do |yard|
    yard.files = ['models/**/*.rb', 'lib/**/*.rb']
end
task :doc => :yard

