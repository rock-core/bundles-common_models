# frozen_string_literal: true

require "common_models/models/devices/gazebo/entity"
require "common_models/models/devices/gazebo/link"
require "common_models/models/services/joints_control_loop"
require "common_models/models/services/pose"
require "common_models/models/services/velocity"

module CommonModels
    module Devices
        module Gazebo
            device_type "Model" do
                provides Entity

                extend_device_configuration do
                    # The RootModel that supports this model
                    def gazebo_root_model
                        to_instance_requirements.arguments[:model_dev]
                    end
                end

                # Rename status_out and command_in to something that talks about
                # joints
                input_port "joints_cmd", "/base/samples/Joints"
                output_port "joints_status", "/base/samples/Joints"
                provides Services::JointsControlledSystem,
                         "command_in" => "joints_cmd",
                         "status_out" => "joints_status"
            end
        end
    end
end
