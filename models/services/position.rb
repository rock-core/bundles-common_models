import_types_from 'base'

module CommonModels
    module Services
        # Provider of a position, i.e. only of the translation part of a
        # transformation
        data_service_type 'Position' do
            output_port 'position_samples', '/base/samples/RigidBodyState'
        end
    end
end
