import_types_from 'base'

module CommonModels
    module Services
        # Provider of a frame transformation
        data_service_type 'Transformation' do
            output_port 'transformation', '/base/samples/RigidBodyState'
        end
    end
end
