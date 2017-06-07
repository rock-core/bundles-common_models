import_types_from 'base'

module CommonModels
    module Services
        # Provider of distance-to-ground
        #
        # This is common in underwater systems, where the distance to ground can be
        # measured directly
        data_service_type 'GroundDistance' do
            output_port 'distance', '/base/samples/RigidBodyState'
        end
    end
end
