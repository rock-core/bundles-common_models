require 'common_models/models/devices/gazebo/entity'
require 'common_models/models/services/position'

module CommonModels
    module Devices
        module Gazebo
            device_type 'GPS' do
                provides Entity
                provides Services::Position
            end
        end
    end
end

