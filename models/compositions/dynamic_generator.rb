# frozen_string_literal: true

require "concurrent"
require "common_models/models/compositions/data_generator"

module CommonModels
    module Compositions
        # Generic implementation of components that generate dynamic vales on their ports
        #
        # A specific dynamic generator task can be generated like a ConstantGenerator.
        # That is, using the {DynamicGenerator.for_type},
        # {DynamicGenerator.for_data_service}, or the more generic {DunamicGenerator.for},
        # which resolves into one the previously mentioned methods.
        #
        # The values that are generated can be determined initially via the values
        # argument. It must be set as a hash with the ports name as keys. Afterwards, the
        # values can be overwritten by assigning to the values attribute.
        #
        # @example create and deploy a task that writes a double value of 0.2 initially,
        # and can be changed dynamically at any time
        #   DoubleGenerator = DynamicGenerator.for("/double")
        #   Syskit.conf.use_ruby_tasks DoubleGenerator => "double_dynamic_gen"
        #   mission = DoubleGenerator.with_arguments(:values => Hash["out" => 10])
        #   add_mission(mission)
        #   mission.values = { "out" => 42 }
        class DynamicGenerator < DataGenerator
            def update_properties # rubocop:disable Lint/UselessMethodDefinition
                super
            end

            event :start do |context|
                @values = Concurrent::AtomicReference.new
                @values.set(arguments[:values])

                super(context)
            end

            # Sets the {#values} argument
            def values=(setpoint)
                # Freeze the setpoint before passing it to the atomic reference for
                # thread safety
                setpoint = setpoint.transform_keys(&:to_s).freeze
                setpoint.each_key do |port_name|
                    unless find_port(port_name)
                        raise ArgumentError,
                              "#{port_name} is not a known port of #{self}."
                    end
                end
                if @values
                    @values.set(setpoint)
                else
                    arguments[:values] = setpoint
                end
            end

            def values
                @values.get
            end
        end
    end
end
