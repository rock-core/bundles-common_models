import_types_from 'base'

module CommonModels
    module Services
        # Provider of only the Z (altitude/depth) part of a position
        #
        # This is a common provider in underwater systems, where the absolute depth
        # can easily be measured with a good accuracy
        data_service_type 'ZProvider' do
            output_port 'z_samples', '/base/samples/RigidBodyState'
        end
    end
end
