require 'models/devices/gazebo/entity'
require 'models/services/pose'
require 'models/services/velocity'
require 'models/services/transformation'

module CommonModels
    module Devices
        module Gazebo
            device_type 'Link' do
                provides Entity

                output_port 'link_state_samples', '/base/samples/RigidBodyState'

                provides Services::Pose,
                    'pose_samples' => 'link_state_samples'
                provides Services::Transformation,
                    'transformation' => 'link_state_samples'
                provides Services::Velocity,
                    'velocity_samples' => 'link_state_samples'
            end
        end
    end
end
