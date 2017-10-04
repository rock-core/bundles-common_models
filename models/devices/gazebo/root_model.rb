require 'models/devices/gazebo/model'
require 'models/devices/gazebo/link'

module CommonModels
    module Devices
        module Gazebo
            device_type 'RootModel' do
                provides Model

                provides Services::Pose
                provides Services::Velocity,
                    'velocity_samples' => 'pose_samples'
            end
        end
    end
end
