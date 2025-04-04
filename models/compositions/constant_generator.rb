# frozen_string_literal: true

require "common_models/models/compositions/data_generator"

module CommonModels
    module Compositions
        # Generic implementation of components that generate constant values on
        # their ports
        #
        # A specific constant generator task can be generated from the name of a
        # data type with {ConstantGenerator.for_type}. It can also be generated from
        # a data service model with {ConstantGenerator.for_data_service}. In the
        # first case, the port name will always be 'out'. In the second case, the
        # task will have the same ports than the data service (including input
        # ports).
        #
        # The values that should be generated are passed through the {values}
        # argument.
        #
        # @example create and deploy a task that generates a constant double value of 0.2
        #   DoubleGenerator = ConstantGenerator.for_type('/double')
        #   Syskit.conf.use_ruby_tasks DoubleGenerator => 'double_gen'
        #   add_mission DoubleGenerator.with_arguments(:values => Hash['out' => 10])
        class ConstantGenerator < CommonModels::Compositions::DataGenerator
            # Values that should be pushed on the ports
            #
            # This is a hash of port names to the values
            #
            # @return [{String=>Object}]
            argument :values

            # Sets the {#values} argument
            def values=(setpoint)
                setpoint = setpoint.transform_keys(&:to_s)
                setpoint.each_key do |port_name|
                    unless find_port(port_name)
                        raise ArgumentError,
                              "#{port_name} is not a known port of #{self}."
                    end
                end
                arguments[:values] = setpoint
            end

            def values
                arguments[:values]
            end
        end
    end
end
