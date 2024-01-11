# frozen_string_literal: true

require "common_models/models/devices/gazebo/entity"
require "common_models/models/services/laser_scan"
require "common_models/models/services/depth_map"

module CommonModels
    module Devices
        module Gazebo
            # Representation of gazebo's 'ray' sensor
            device_type "Ray" do
                provides Entity
                provides CommonModels::Services::LaserScan
                provides CommonModels::Services::DepthMap
            end
        end
    end
end
