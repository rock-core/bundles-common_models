import_types_from 'base'

module CommonModels
    module Services
        data_service_type 'Acceleration' do
            output_port 'acceleration_samples', '/base/samples/RigidBodyAcceleration'
        end
    end
end
