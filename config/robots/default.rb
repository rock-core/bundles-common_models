## One can require the configuration from another robot, for instance if one has
## a common robot class with minor modifications
#
# require 'config/robots/robot_class'

# Block evaluated at the very beginning of the Roby app initialization
Robot.init do
    ## You can load plugins here
    # Roby.app.using 'fault_injection'
    # Roby.app.using 'syskit'

    ## Change the scheduler
    require 'roby/schedulers/temporal'
    Roby.scheduler = Roby::Schedulers::Temporal.new

    ## You could also change the Roby search path
    # Roby.app.search_path << "separate path"
end

def require_all_except(*path, except: [])
    Dir.glob File.join(*path, '*') do |file|
        if File.exist?(file) && File.extname(file) == '.rb'
            if !except.include?(File.basename(file))
                require file
            end
        end
    end
end

# Block evaluated to load the models this robot requires
Robot.requires do
    Roby.app.auto_load_all_task_libraries = true

    excluded_services      = []
    excluded_compositions = []

    if !Roby.app.default_loader.has_typekit?('controldev')
        excluded_services << 'raw_input_command.rb'
    end

    if !Roby.app.default_loader.has_typekit?('iodrivers_base')
        excluded_services << 'raw_io.rb'
    end

    if !Roby.app.default_loader.has_project?('trajectory_follower')
        excluded_compositions << 'trajectory_follower_control_loop.rb'
    end

    # Load all in services/ and compositions/ except those things that have a
    # dependency
    #
    # Exclude joints_trajectory_open_loop_control.rb, it conflicts with
    # joints_trajectory_control_loop
    require_all_except Roby.app.app_dir, 'models', 'services',
        except: [excluded_services, 'joints_trajectory_open_loop_control.rb']
    require_all_except Roby.app.app_dir, 'models', 'compositions', except: excluded_compositions
end

# Block evaluated to configure the system, that is set up values in Roby's Conf
# and State
Robot.config do
end

# Block evaluated when the Roby app is fully setup, and the robot ready to
# start. This is where one usually adds permanent tasks and/or status lines
Robot.controller do
end

# Setup of the robot's main action interface
#
# Add use statements here, as e.g.
#
#   use CommonModels::Actions::MyActionInterface
#
# or, if you're using syskit
#
#   use_profile CommonModels::Profiles::BaseProfile
#
Robot.actions do
end

