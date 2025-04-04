# frozen_string_literal: true

require "concurrent"

module CommonModels
    module Compositions
        # Generic implementation of components that generate data annotated through the
        # #values= method call.
        #
        # @example create and deploy a task that writes a double value of 0.2 initially,
        # and can be changed dynamically at any time
        #   class MyGenerator < CommonModels::Compositions::DataGenerator
        #       def values=(value)
        #            do stuff
        #       end
        #
        #       def values
        #           return stuff
        #       end
        #   end
        #   DoubleGenerator = MyGenerator.for("/double")
        #   Syskit.conf.use_ruby_tasks DoubleGenerator => "double_gen"
        #   mission = DoubleGenerator.with_arguments(:values => Hash["out" => 10])
        #   add_mission(mission)
        #   mission.values = { "out" => 42 }
        class DataGenerator < Syskit::RubyTaskContext
            # The write period in seconds
            argument :period, default: 0.1

            # @api private
            #
            # The writing thread. This is an attr reader for testing purposes only
            attr_reader :write_thread

            def initialize(*, **)
                super

                @write_thread = nil
            end

            def values=(value)
                raise NotImplementedError, "#values= method must be implemented"
            end

            def values
                raise NotImplementedError, "#values method must be implemented"
            end

            def update_properties # rubocop:disable Lint/UselessMethodDefinition
                super
            end

            event :start do |context|
                @write_thread_exit = exit_event = Concurrent::Event.new
                period = self.period
                @write_thread = Thread.new do
                    # Disable exception reporting. Uncaught exceptions are reported
                    # through the write_thread_error event
                    Thread.current.report_on_exception = false
                    until exit_event.set?
                        next unless values

                        values.each do |port_name, value|
                            orocos_task.port(port_name).write(value)
                        end
                        exit_event.wait(period)
                    end
                end
                super(context)
            end

            event :write_thread_error
            signal write_thread_error: :interrupt

            poll do
                unless @write_thread.alive?
                    begin
                        result = @write_thread.value
                        write_thread_error_event.emit(result) unless stop_event.pending?
                    rescue ::Exception => e # rubocop:disable Lint/RescueException
                        write_thread_error_event.emit(e)
                    end
                end
            end

            event :stop do |context|
                @write_thread_exit.set
                begin
                    @write_thread.join
                rescue ::Exception # rubocop:disable Lint/RescueException,Lint/SuppressedException
                end
                super(context)
            end

            # Shortcut for {for_type} and {for_data_service}
            #
            # It dispatches based on the argument type
            def self.for(object)
                if Syskit::Models.is_model?(object)
                    for_data_service(object)
                else
                    for_type(object)
                end
            end

            # Create a DataGenerator for a given data type. A plain DataGenerator is not
            # enough to have a working ruby task. Only use this for a class that inherits
            # from the DataGenerator
            #
            # The generated task model has a single 'out' port of the required type
            #
            # It will return different models if called twice from the same data
            # type. This means that you can't use it as-is in e.g. a composition
            # definition, you must assign it first to a constant, and use the
            # constant
            #
            #
            #   DoubleGenerator = MyGenerator.for_type '/double'
            #   # From now on, use DoubleGenerator
            #
            # @return [Model<MyGenerator>]
            def self.for_type(type_name)
                generator = new_submodel
                port = generator.output_port "out", type_name
                port.doc "The generated value, from the values argument to the task. " \
                         "Set it to a hash with a single out key and the value to " \
                         "generate."
                generator
            end

            # Create a DataGenerator for a given data service
            #
            # The generated task model has the same ports than the data service
            #
            # Given a data service, the returned value will always be identical. If
            # you want to customize the model in different ways, subclass it. For
            # instance:
            #
            #   ImageGenerator = MyGenerator.for_data_service(Base::ImageSrv)
            #   class AutoStopGenerator < ImageGenerator
            #      poll do
            #        if lifetime > 5
            #          stop_event.emit
            #        end
            #      end
            #   end
            #
            # @return [Model<MyGenerator>]
            def self.for_data_service(service_model, as: "template")
                if service_model.const_defined_here?("Generator")
                    return service_model.const_get(:Generator)
                end

                generator = new_submodel
                service_model.each_input_port do |port|
                    generator.input_port port.name, port.orocos_type_name
                end
                service_model.each_output_port do |port|
                    generator.output_port port.name, port.orocos_type_name
                end
                generator.provides service_model, as: as
                service_model.const_set :Generator, generator
                generator
            end
        end
    end
end
