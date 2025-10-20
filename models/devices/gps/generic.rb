# frozen_string_literal: true

require "common_models/models/services/position"

module CommonModels
    module Devices
        module GPS
            device_type "Generic" do
                output_port "nwu_position_samples", "/base/samples/RigidBodyState"
                provides CommonModels::Services::Position,
                         "position_samples" => "nwu_position_samples"
            end
        end
    end
end
