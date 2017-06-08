import_types_from 'base'

module CommonModels
    module Services
        # Representation of the rotation part of a full pose
        data_service_type 'Rotation' do
            output_port 'rotation_samples', '/base/samples/RigidBodyState'
        end
    end
end
