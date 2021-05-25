# frozen_string_literal: true

require "common_models/models/blueprints/devices"

class OroGen::CameraUsb::Task
    driver_for Dev::Sensors::Cameras::USB, as: "driver"

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
