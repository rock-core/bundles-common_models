require 'common_models/models/devices/gazebo/entity'
require 'common_models/models/services/pose'
require 'common_models/models/services/velocity'
require 'common_models/models/services/transformation'

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
