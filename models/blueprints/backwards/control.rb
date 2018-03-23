require 'common_models/backward_module_name'
Syskit.warn_about_new_naming_convention
Syskit.warn "The Base::ControlLoop functionality that was defined in models/blueprints/pose is now defined under models/compositions/, and has been renamed to match the new Syskit naming conventions"
module Base
    backward_compatible_constant :ControllerSrv         , "Rock::Services::Controller"         , 'common_models/models/services/controller'
    backward_compatible_constant :ControlledSystemSrv         , "Rock::Services::ControlledSystem"         , 'common_models/models/services/controlled_system'

    if Roby.app.backward_compatible_naming?
        Syskit.warn "  in addition, the ControlLoop declaration API has changed, please look at the API documentation"
        Syskit.warn "  of Rock::Services::ControlLoop in models/services/control_loop"
        Syskit.warn "  and of Rock::Compositions::ControlLoop in models/compositions/control_loop"
        require 'common_models/models/compositions/control_loop'
        class ControlLoop < Rock::Compositions::ControlLoop
            def self.declare(name, control_type, options = Hash.new)
                options, _ = Kernel.filter_options options, :feedback_type

                if feedback_type = options[:feedback_type]
                    Rock::Services::ControlLoop.declare(name, control_type, feedback_type)
                    Rock::Compositions::ControlLoop.declare(name, control_type, feedback_type)
                else
                    Rock::Services::ControlLoop.declare_open_loop(name, control_type)
                    Rock::Compositions::ControlLoop.declare_open_loop(name, control_type)
                end
                declare_backward_compatible(name, control_type, options)
            end

            def self.declare_backward_compatible(name, control_type, options = Hash.new)
                options, _ = Kernel.filter_options options, :feedback_type

                if feedback_type = options[:feedback_type]
                    status = Rock::Services::ControlLoop.status_for(name)
                    controlled_system = Rock::Services::ControlLoop.
                        controlled_system_for(name)
                    controller = Rock::Services::ControlLoop.
                        controller_for(name)
                    status_backward = Base.data_service_type "#{name}StatusSrv" do
                        output_port "status_samples", feedback_type
                    end
                    status.provides status_backward, 'status_samples' => 'status_out'
                else
                    controller = Rock::Services::ControlLoop.
                        open_loop_controller_for(name)
                    controlled_system = Rock::Services::ControlLoop.
                        open_loop_controlled_system_for(name)
                end

                command_consumer_srv = Base.data_service_type "#{name}CommandConsumerSrv" do
                    input_port "cmd_in", control_type
                end
                controlled_system.provides command_consumer_srv, 'cmd_in' => 'command_in'

                command_provider_srv = Base.data_service_type "#{name}CommandSrv" do
                    output_port "command_samples", control_type
                end

                Base.const_set "#{name}ControllerSrv", controller
                Base.const_set "#{name}ControlledSystemSrv", controlled_system
                Base.const_set "#{name}CommandConsumerSrv", command_consumer_srv
                Base.const_set "#{name}CommandSrv", command_provider_srv
            end
        end
    else
        Syskit.error "  in addition, the ControlLoop declaration API has changed, please look at the API documentation"
        Syskit.error "  of Rock::Services::ControlLoop in models/services/control_loop"
        Syskit.error "  and of Rock::Compositions::ControlLoop in models/compositions/control_loop"
        Syskit.error "  to get the old names, you still have the option of adding"
        Syskit.error "    Roby.app.backward_compatible_naming = true"
        Syskit.error "  in config/init.rb, but beware that this option will be removed in the near future"
    end
end


if Roby.app.backward_compatible_naming?
    Syskit.warn "  the Actuator* control loop and services are now available under Rock::Services::ActuatorXXX and Rock::Compositions::ActuatorXXX, and can be loaded with models/services/actuator_control_loop and models/compositions/actuator_control_loop"
    Syskit.warn "  the Joints* control loop and services are now available under Rock::Services::JointsXXX and Rock::Compositions::JointsXXX, and can be loaded with models/services/joints_control_loop and models/compositions/joints_control_loop"
    Syskit.warn "  the Motion2D* control loop and services are now available under Rock::Services::Motion2DXXX and Rock::Compositions::Motion2DXXX, and can be loaded with models/services/motion2d_control_loop and models/compositions/motion2d_control_loop"
    require 'common_models/models/compositions/actuator_control_loop'
    require 'common_models/models/compositions/joints_control_loop'
    require 'common_models/models/compositions/motion2d_control_loop'
    Base::ControlLoop.declare_backward_compatible(
        'Actuator', '/base/actuators/Command', feedback_type: '/base/actuators/Status')
    Base::ControlLoop.declare_backward_compatible(
        'Joints', '/base/commands/Joints', feedback_type: '/base/samples/Joints')
    Base::ControlLoop.declare_backward_compatible(
        'Motion2D', '/base/commands/Motion2D')
else
    Syskit.error "  the Actuator* control loop and services are now available under Rock::Services::ActuatorXXX and Rock::Compositions::ActuatorXXX, and can be loaded with models/services/actuator_control_loop and models/compositions/actuator_control_loop"
    Syskit.error "  the Joints* control loop and services are now available under Rock::Services::JointsXXX and Rock::Compositions::JointsXXX, and can be loaded with models/services/joints_control_loop and models/compositions/joints_control_loop"
    Syskit.error "  the Motion2D* control loop and services are now available under Rock::Services::Motion2DXXX and Rock::Compositions::Motion2DXXX, and can be loaded with models/services/motion2d_control_loop and models/compositions/motion2d_control_loop"
    Syskit.error "  to get the old names, you still have the option of adding"
    Syskit.error "    Roby.app.backward_compatible_naming = true"
    Syskit.error "  in config/init.rb, but beware that this option will be removed in the near future"
end

