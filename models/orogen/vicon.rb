require 'common_models/models/blueprints/pose'
Dev::Sensors.device_type 'Vicon' do
    provides Base::PoseSrv
end

class OroGen::Vicon::Task
    driver_for Dev::Sensors::Vicon, :as => 'driver'
end
