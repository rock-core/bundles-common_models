require 'common_models/models/blueprints/timestamping'
require 'common_models/models/blueprints/devices'

module Dev
    module Sensors
        module Teledyne 
            device_type 'Explorer' do
                provides Base::GroundDistanceSrv
                provides Base::VelocitySrv
            end
        end
    end
end



class OroGen::DvlTeledyne::Task
    driver_for Dev::Sensors::Teledyne::Explorer, :as => 'driver', "distance" => "ground_distance", "velocity_samples" => "velocity_samples"
end

