require 'common_models/models/blueprints/devices'
require 'common_models/models/blueprints/timestamping'

class OroGen::Hokuyo::Task
    driver_for Dev::Sensors::Hokuyo, :as => 'driver'
    provides Base::TimestampInputSrv, :as => 'timestamps'
    provides Base::LaserRangeFinderSrv, :as => 'scanner'

    transformer do
        associate_frame_to_ports 'laser', 'scans'
    end
end

