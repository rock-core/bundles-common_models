# frozen_string_literal: true

require "common_models/models/devices/gazebo/entity"
require "common_models/models/services/pose_and_twist"
require "common_models/models/services/transformation"
require "common_models/models/services/acceleration"
require "common_models/models/services/wrench"

module CommonModels
    module Devices
        module Gazebo
            device_type "Link" do
                provides Entity

                output_port "link_state_samples", "/base/samples/RigidBodyState"

                provides Services::PoseAndTwist,
                         "pose_and_twist_samples" => "link_state_samples"
                provides Services::Transformation,
                         "transformation" => "link_state_samples"
                provides Services::Acceleration
                provides Services::Wrench
            end
        end
    end
end
