# frozen_string_literal: true

require "common_models/models/devices/bus/can"

Syskit.extend_model OroGen.canbus.Task do # rubocop:disable Metrics/BlockLength
    driver_for CommonModels::Devices::Bus::CAN, as: "driver"

    # This declares that all devices attached to this bus should use the 'in'
    # port of the component. Otherwise, syskit will assume that a new dynamic
    # input port should be created
    provides CommonModels::Devices::Bus::CAN::BusInSrv, as: "to_bus"

    def update_properties # rubocop:disable Lint/UselessMethodDefinition
        super
    end

    def configure
        super

        bus_name = self.driver_dev.name # self.canbus_name
        each_declared_attached_device do |dev|
            can_id, can_mask = dev.can_id
            unless dev.can_id
                raise ArgumentError, "No can id/mask given for #{dev}"
            end

            name = dev.name
            Robot.info "#{bus_name}: watching #{name} on 0x#{can_id.to_s.to_i(16)}/#{can_mask.to_s.to_i(16)}"
            orocos_task.watch(name, can_id, can_mask)
        end
    end

    stub do
        def stub_configured_watches
            @stub_configured_watches ||= []
        end

        def watch(name, can_id, can_mask)
            stub_configured_watches << [name, can_id, can_mask]
            create_input_port "w#{name}", "/canbus/Message"
            create_output_port name, "/canbus/Message"
        end
    end
end
