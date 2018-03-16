require 'common_models/models/devices/gazebo/model'
require 'common_models/models/devices/gazebo/link'

module CommonModels
    module Devices
        module Gazebo
            device_type 'RootModel' do
                provides Model

                input_port 'model_pose', '/base/samples/RigidBodyState'
                
                provides Services::Pose
                provides Services::Velocity,
                    'velocity_samples' => 'pose_samples'
            end
        end
    end
end
