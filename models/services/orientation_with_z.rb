import_types_from 'base'
require 'common_models/models/services/orientation'
require 'common_models/models/services/z_provider'

module CommonModels
    module Services
        # Provider of a full orientation as well as the altitude/depth part of the
        # position
        #
        # This is a common provider in underwater systems, where the absolute depth
        # can easily be measured with a good accuracy
        data_service_type 'OrientationWithZ' do
            output_port 'orientation_z_samples', '/base/samples/RigidBodyState'
            provides Orientation, 'orientation_samples' => 'orientation_z_samples'
            provides ZProvider, 'z_samples' => 'orientation_z_samples'
        end
    end
end
