require 'common_models/models/blueprints/sensors'
Dev::Sensors.device_type 'SickLMS' do
    provides Base::LaserRangeFinderSrv
end

class OroGen::LaserscannerSick::Task
    driver_for Dev::Sensors::SickLMS, :as => 'device'

    transformer do
        associate_frame_to_ports 'laser', 'scan'
    end
end
