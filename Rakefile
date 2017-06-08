require "bundler/gem_tasks"
require 'yard'
require 'yard/rake/yardoc_task'
require 'roby/app/rake'

task :default

Roby::App::Rake::TestTask.new do |t|
    # We need to do a little more work than usual here. We can only assume that
    # rock.core is available, but some models are coming from other packages.
    require 'orogen'
    loader = OroGen::Loaders::PkgConfig.new 'gnulinux'
    if !loader.has_project?('trajectory_follower')
        t.excludes << 'test/compositions/test_trajectory_follower_control_loop.rb'
    end
    if !loader.has_typekit?('canbus')
        t.excludes << 'test/devices/bus/test_can.rb'
    end
    if !loader.has_typekit?('iodrivers_base')
        t.excludes << 'test/devices/bus/test_raw_io.rb'
    end
    if !loader.has_typekit?('controldev')
        t.excludes << 'test/devices/input/graupner/test_mc20.rb'
    end
    puts t.excludes
end

YARD::Rake::YardocTask.new do |yard|
    yard.files = ['models/**/*.rb', 'lib/**/*.rb']
end
task :doc => :yard

