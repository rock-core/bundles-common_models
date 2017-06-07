
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
        class ConstantGenerator < Syskit::RubyTaskContext
            # Values that should be pushed on the ports
            #
            # This is a hash of port names to the values
            #
            # @return [{String=>Object}]
            argument :values

            # The write period in seconds
            argument :period, default: 0.1

            # @api private
            #
            # The writing thread
            attr_reader :write_thread

            # Sets the {#values} argument
            def values=(setpoint)
                setpoint = setpoint.map_key do |port_name, _|
                    port_name = port_name.to_s
                    if !find_port(port_name)
                        raise ArgumentError, "#{port_name} is not a known port of #{self}."
                    end
                    port_name
                end
                arguments[:values] = setpoint
            end

            event :start do |context|
                @write_thread_exit = exit_event = Concurrent::Event.new
                period = self.period
                @write_thread = Thread.new do
                    while !exit_event.set?
                        values.each do |port_name, value|
                            orocos_task.port(port_name).write(value)
                        end
                        exit_event.wait(period)
                    end
                end
                super(context)
            end

            poll do
                if !@write_thread.alive?
                    begin
                        @write_thread.value
                        aborted! if !stop_event.pending?
                    rescue ::Exception => e
                        aborted!
                    end
                end
            end

            event :stop do |context|
                @write_thread_exit.set
                begin
                    @write_thread.join
                rescue ::Exception
                end
                super(context)
            end

            # Shortcut for {for_type} and {for_data_service}
            #
            # It dispatches based on the argument type
            def self.for(object)
                if Syskit::Models.is_model?(object)
                    return for_data_service(object)
                else
                    return for_type(object)
                end
            end

            # Create a ConstantGenerator for a given data type
            #
            # The generated task model has a single 'out' port of the required type
            #
            # It will return different models if called twice from the same data
            # type. This means that you can't use it as-is in e.g. a composition
            # definition, you must assign it first to a constant, and use the
            # constant
            #
            #   DoubleGenerator = ConstantGenerator.for_type '/double'
            #   # From now on, use DoubleGenerator
            #
            # @return [Model<ConstantGenerator>]
            def self.for_type(type_name)
                generator = ConstantGenerator.new_submodel
                generator.output_port 'out', type_name
                generator
            end

            # Create a ConstantGenerator for a given data service
            #
            # The generated task model has the same ports than the data service
            #
            # Given a data service, the returned value will always be identical. If
            # you want to customize the model in different ways, subclass it. For
            # instance:
            #   
            #   ImageGenerator = ConstantGenerator.for_data_service(Base::ImageSrv)
            #   class AutoStopGenerator < ImageGenerator
            #      poll do
            #        if lifetime > 5
            #          stop_event.emit
            #        end
            #      end
            #   end
            #
            # @return [Model<ConstantGenerator>]
            def self.for_data_service(service_model, options = Hash.new)
                if service_model.const_defined_here?('Generator')
                    return service_model.const_get(:Generator)
                end

                options = Kernel.validate_options options,
                    as: 'template'

                generator = ConstantGenerator.new_submodel
                service_model.each_input_port do |port|
                    generator.input_port port.name, port.orocos_type_name
                end
                service_model.each_output_port do |port|
                    generator.output_port port.name, port.orocos_type_name
                end
                generator.provides service_model, as: options[:as]
                service_model.const_set :Generator, generator
                generator
            end
        end
    end
end
