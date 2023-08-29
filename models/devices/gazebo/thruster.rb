# frozen_string_literal: true

require "common_models/models/services/thruster"
require "common_models/models/devices/gazebo/entity"
module CommonModels
    module Devices
        module Gazebo
            device_type "Thruster" do
                provides Entity
                provides Services::Thruster
                provides Services::ThrusterController
            end
        end
    end
end
