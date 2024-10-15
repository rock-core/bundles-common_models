# frozen_string_literal: true

require "yard"
require "yard/rake/yardoc_task"
require "roby/app/rake"

task :default

Roby::App::Rake::TestTask.new do |t|
    # We need to do a little more work than usual here. We can only assume that
    # rock.core is available, but some models are coming from other packages.
    require "orogen"
    loader = OroGen::Loaders::PkgConfig.new "gnulinux"
    if t.respond_to?(:excludes)
        unless loader.has_project?("trajectory_follower")
            t.excludes << "test/compositions/test_trajectory_follower_control_loop.rb"
        end
        unless loader.has_typekit?("canbus")
            t.excludes << "test/devices/bus/test_can.rb"
        end
        unless loader.has_typekit?("iodrivers_base")
            t.excludes << "test/devices/bus/test_raw_io.rb"
        end
        unless loader.has_typekit?("controldev")
            t.excludes << "test/devices/input/graupner/test_mc20.rb"
        end
    end
end

task "rubocop" do
    raise "rubocop failed" unless system(ENV["RUBOCOP_CMD"] || "rubocop")
end
task "test" => "rubocop" if ENV["RUBOCOP"] != "0"

YARD::Rake::YardocTask.new do |yard|
    yard.files = ["models/**/*.rb", "lib/**/*.rb"]
end
task doc: :yard
