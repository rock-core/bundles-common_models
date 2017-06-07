import_types_from 'base'

module CommonModels
    module Services
        # Provider of an orientation, i.e. only of the rotation part of a
        # transformation
        data_service_type 'Orientation' do
            output_port 'orientation_samples', '/base/samples/RigidBodyState'
        end
    end
end
