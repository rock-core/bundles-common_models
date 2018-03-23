require 'common_models/models/blueprints/devices'

class OroGen::CameraUsb::Task
    driver_for Dev::Sensors::Cameras::USB, :as => 'driver'
    
    def configure
        super
        if p = robot_device.period
            orocos_task.fps = (1.0 / p).round
        end
    end
end


