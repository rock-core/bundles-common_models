import_types_from 'base'

module CommonModels
    module Services
        # Provider of a full velocity
        data_service_type 'Velocity' do
            output_port 'velocity_samples', '/base/samples/RigidBodyState'
        end
    end
end
