require 'common_models/models/blueprints/timestamping'
require 'common_models/models/blueprints/devices'

class OroGen::XsensImu::Task
    # Additional information to allow for the transformer's automatic
    # configuration
    transformer do
        associate_frame_to_ports "imu", "calibrated_sensors"
        transform_output "orientation_samples", "imu" => "world"
    end
    
    driver_for Dev::Sensors::XsensAHRS, :as => 'driver'
    provides Base::TimestampInputSrv, 'timestamps' => 'hard_timestamps', :as => 'timestamps'
end

