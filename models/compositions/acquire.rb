# frozen_string_literal: true

module CommonModels
    module Compositions
        # Functor that generates a composition which emits success when a
        # sample has been received on each port(s) of the given service.
        # The sample(s) are passed as context to the success event, as a
        # `{ port_name: sample }` hash.
        #
        # The service is added to the composition as the 'data_source' child
        #
        # @example acquire a pose. In the following composition model,
        #   AcquirePose.success_event will be emited when one sample is received
        #   on the pose_samples port of the data_source child. The success event's
        #   context will be of the form { pose_samples: sample }
        #
        #     AcquirePose = CommonModels::Compositions
        #         .Acquire(CommonModels::Services::Pose)
        #
        def self.Acquire(service) # rubocop:disable Naming/MethodName
            cmp_m = Syskit::Composition.new_submodel
            cmp_m.add service, as: 'data_source'
            cmp_m.script do
                ports = {}
                result = {}

                service.each_output_port do |port|
                    ports[port.name.to_sym] = data_source_child
                                              .find_port(port.name).reader
                end

                poll do
                    ready = ports.each.all? do |port_name, port|
                        result[port_name] ||= port.read_new
                    end
                    success_event.emit(result) if ready
                end
            end
            cmp_m
        end
    end
end
