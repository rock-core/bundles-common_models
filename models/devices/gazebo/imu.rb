require 'common_models/models/devices/gazebo/entity'
require 'common_models/models/services/orientation'
require 'common_models/models/services/imu_calibrated_sensors'

module CommonModels
    module Devices
        module Gazebo
            # Representation of gazebo's 'imu' sensor
            device_type 'Imu' do
                provides Entity
                provides CommonModels::Services::Orientation
                provides CommonModels::Services::IMUCalibratedSensors
            end
        end
    end
end
