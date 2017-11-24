require 'models/devices/gazebo/entity'
require 'models/devices/gazebo/link'
require 'models/services/joints_control_loop'
require 'models/services/pose'
require 'models/services/velocity'

module CommonModels
    module Devices
        module Gazebo
            device_type 'Model' do
                provides Entity

                # Rename status_out and command_in to something that talks about
                # joints
                input_port 'joints_cmd', '/base/samples/Joints'
                output_port 'joints_status', '/base/samples/Joints'
                provides Services::JointsControlledSystem,
                    'command_in' => 'joints_cmd',
                    'status_out' => 'joints_status'
            end
        end
    end
end
