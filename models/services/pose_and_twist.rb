# frozen_string_literal: true

import_types_from "base"

require "common_models/models/services/pose"
require "common_models/models/services/velocity"

module CommonModels
    module Services # :nodoc:
        # Full SE3 Pose and Twist. Linear angular position (velocity)
        data_service_type "PoseAndTwist" do
            output_port "pose_and_twist_samples", "/base/samples/RigidBodyState"

            provides CommonModels::Services::Pose,
                     "pose_samples" => "pose_and_twist_samples"
            provides CommonModels::Services::Velocity,
                     "velocity_samples" => "pose_and_twist_samples"
        end
    end
end
