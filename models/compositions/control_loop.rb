require 'common_models/models/services/control_loop'

module CommonModels
    module Compositions
        # Abstract base composition for all control loops
        class ControlLoop < Syskit::Composition
            abstract

            add Services::Controller, :as => 'controller'
            add Services::ControlledSystem, :as => 'controlled_system'

            # Avoid generating unnecessary cross-specializations
            #
            # This is a performance boost, mainly. Without this, syskit would
            # "prepare" cross-specializations that would, in the end, never be
            # used.
            add_specialization_constraint do |spec0, spec1|
                %w{controller controlled_system}.all? do |child_name|
                    controller0 = spec0.find_specialization(
                        child_name, Services::Controller)
                    controller1 = spec1.find_specialization(
                        child_name, Services::Controller)
                    if controller0 && controller1
                        m0 = controller0.first
                        m1 = controller1.first
                        if !m0.fullfills?(m1) && !m1.fullfills?(m0)
                            next(false)
                        end
                    end

                    controlled0 = spec0.find_specialization(
                        child_name, Services::ControlledSystem)
                    controlled1 = spec1.find_specialization(
                        child_name, Services::ControlledSystem)
                    if controlled0 && controlled1
                        m0 = controlled0.first
                        m1 = controlled1.first
                        if !m0.fullfills?(m1) && !m1.fullfills?(m0)
                            next(false)
                        end
                    end

                    true
                end
            end

            def self.declare_open_loop(name)
                controller_srv =
                    Services::ControlLoop.open_loop_controller_for(name)
                controlled_system_srv =
                    Services::ControlLoop.open_loop_controlled_system_for(name)

                specialize controller_child => controlled_system_srv do
                    export controller_child.command_in_port
                    provides controlled_system_srv, :as => "open_loop_#{name.snakecase}"
                end
                specialize controller_child => controller_srv,
                    controlled_system_child => controlled_system_srv do
                    controller_child.command_out_port.connect_to controlled_system_child.command_in_port
                end
            end

            # Declare standard specializations of {ControlLoop} for a certain
            # type of controller
            #
            # This builds on top of services built by
            # {Services::ControlLoop.declare}. The name provided as argument has
            # to match the one given to the service declaration method
            #
            # @param [String] name the controller name
            # @return [void]
            def self.declare(name)
                declare_open_loop(name)

                controller_srv =
                    Services::ControlLoop.controller_for(name)
                controlled_system_srv =
                    Services::ControlLoop.controlled_system_for(name)

                specialize controller_child => controlled_system_srv do
                    export controller_child.command_in_port
                    export controller_child.status_out_port
                    provides controlled_system_srv, :as => "#{name}"
                end
                specialize controller_child => controller_srv,
                    controlled_system_child => controlled_system_srv do
                    controlled_system_child.status_out_port.connect_to controller_child.status_in_port
                end
            end
        end
    end
end

