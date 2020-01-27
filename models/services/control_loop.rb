require "common_models/models/services/controller.rb"
require "common_models/models/services/controlled_system.rb"

module CommonModels
    module Services
        module ControlLoop
            # Exception raised by {.declare_open_loop} and {.declare} if a
            # control loop of the requested name has already been defined
            class AlreadyDeclared < ArgumentError; end

            # @api private
            #
            # Helper method for {.declare_open_loop} and {.declare}
            #
            # @raise [AlreadyDeclared]
            def self.check_already_declared(name, *suffixes, namespace: Services)
                suffixes.each do |suffix|
                    if namespace.const_defined_here?(srv_name = "#{name}#{suffix}")
                        existing = namespace.const_get(srv_name)
                        raise AlreadyDeclared, "it seems that the control loop "\
                            "services for #{name} have already been defined: found "\
                            "#{existing}"
                    end
                end
            end


            # Declares standard services, parts of open-loop control systems.
            # The following services are defined, each time prefixed with
            # the provided name
            #
            # OpenLoopController::
            #   open-loop controller, that is a component that generates a
            #   command of type control_type on a command_out port.
            # OpenLoopControlledSystem::
            #   system controlled in open-loop, that is a component that
            #   expects a command of type control_type on a command_in port.
            #
            # @param [String] name the name that should be used to prefix the
            #   generated services
            # @param [String,Model<Typelib::Type>] control_type the type used to
            #   convey control commands, either as name or as a type object
            # @return [(Model<DataService>,Model<DataService>)] the controller,
            #   controlled system pair
            def self.declare_open_loop(name, control_type, namespace: Services)
                check_already_declared(
                    name, "OpenLoopControlledSystem", "OpenLoopController",
                    namespace: namespace
                )

                open_loop_controlled_system =
                    namespace.data_service_type "#{name}OpenLoopControlledSystem" do
                        input_port "command_in", control_type
                        provides ControlledSystem
                    end
                open_loop_controller =
                    namespace.data_service_type "#{name}OpenLoopController" do
                        output_port "command_out", control_type
                        provides Controller
                    end

                this_file = File.expand_path(__FILE__)
                open_loop_controlled_system.definition_location.delete_if { |file, _| file == this_file }
                open_loop_controller.definition_location.delete_if { |file, _| file == this_file }

                return open_loop_controller, open_loop_controlled_system
            end

            # Declares standard services, parts of closed-loop control systems.
            #
            # It defines first the open-loop services by calling
            # {.declare_open_loop}. In addition, it defines the following
            # services, each time prefixed with the provided name
            #
            # Controller::
            #   closed-loop controller, that is a component that generates a
            #   command of type control_type on a command_out port and expects
            #   system feedback on a status_in port of type feedback_type
            # ControlledSystem::
            #   system controlled in closed loop, that is a component that
            #   generates a status of type feedback_type on a status_out port
            #   and expects commands on a command_in port of type
            #   control_type
            # Status::
            #   component that generates the required status information for
            #   the generated controller
            #
            # @param [String] name the name that should be used to prefix the
            #   generated services
            # @param [String,Model<Typelib::Type>] control_type the type used to
            #   convey control commands, either as name or as a type object
            # @param [String,Model<Typelib::Type>] feedback_type the type used to
            #   convey feedback information, either as name or as a type object
            # @return [(Model<DataService>,Model<DataService>)] the controller,
            #   controlled system pair
            def self.declare(name, control_type, feedback_type, namespace: Services)
                check_already_declared(
                    name, "ControlledSystem", "Controller",
                    namespace: namespace
                )

                open_loop_controller, open_loop_controlled_system =
                    declare_open_loop(name, control_type, namespace: namespace)

                feedback_model = namespace.data_service_type "#{name}Status" do
                    output_port "status_out", feedback_type
                end
                controlled_system = namespace.data_service_type "#{name}ControlledSystem" do
                    provides open_loop_controlled_system
                    provides feedback_model
                    provides ControlledSystem
                end
                controlled_system.singleton_class.class_eval do
                    define_method :open_loop_srv do
                        open_loop_controlled_system
                    end
                end
                controller = namespace.data_service_type "#{name}Controller" do
                    provides open_loop_controller
                    input_port "status_in", feedback_type
                    provides Controller
                end
                controller.singleton_class.class_eval do
                    define_method :open_loop_srv do
                        open_loop_controller
                    end
                end

                this_file = File.expand_path(__FILE__)
                feedback_model.definition_location.delete_if { |file, _| file == this_file }
                controlled_system.definition_location.delete_if { |file, _| file == this_file }
                controller.definition_location.delete_if { |file, _| file == this_file }
            end

            # Returns the controller data service defined for this type by
            # {declare}
            def self.open_loop_controller_for(name)
                Services.const_get("#{name}OpenLoopController")
            end

            # Returns the controller data service defined for this type by
            # {declare}
            def self.open_loop_controlled_system_for(name)
                Services.const_get("#{name}OpenLoopControlledSystem")
            end

            # Returns the controller data service defined for this type by
            # {declare}
            def self.controller_for(name)
                Services.const_get("#{name}Controller")
            end

            # Returns the controller data service defined for this type by
            # {declare}
            def self.controlled_system_for(name)
                Services.const_get("#{name}ControlledSystem")
            end

            # Returns the status service defined for this type by {declare}
            def self.status_for(name)
                Services.const_get("#{name}Status")
            end
        end
    end
end



