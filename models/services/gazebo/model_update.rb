import_types_from 'base'

module CommonModels
    module Services
        module Gazebo
            # Service is used to tags tasks that want to get updates about one
            # of the model of a gazebo world
            data_service_type 'ModelUpdate' do
                input_port 'pose', '/base/samples/RigidBodyState'
                input_port 'joints', '/base/samples/Joints'
            end
        end
    end
end
