# frozen_string_literal: true

require "common_models/models/blueprints/devices"
require "common_models/models/blueprints/timestamping"

Syskit.extend_model OroGen.camera_firewire.CameraTask do
    driver_for Dev::Sensors::Cameras::Firewire, as: "driver"
    provides Base::TimestampInputSrv, as: "timestamps"

    def update_properties
        super if defined? super

        if (p = robot_device.period)
            properties.fps = (1.0 / p).round
        end
    end

    def configure
        super
        update_properties unless model.respond_to?(:use_update_properties?)
    end
end
