require 'common_models/models/blueprints/devices'
require 'common_models/models/blueprints/timestamping'

class OroGen::CameraFirewire::CameraTask
    driver_for Dev::Sensors::Cameras::Firewire, :as => 'driver'
    provides Base::TimestampInputSrv, :as => 'timestamps'
    
    def configure
        super
        if p = robot_device.period
            orocos_task.fps = (1.0 / p).round
        end
    end
end

