import_types_from 'base'
require 'common_models/models/services/pose'

module CommonModels
    module Services
        # Represents pose estimators that provide a pose which is locally
        # consistent, but that will stray away from the true global pose in the long
        # run. These estimators should not jump, as it would break the local
        # consistency constraint
        #
        # It is typically an odometry on ground-based systems
        data_service_type 'RelativePose' do
            provides Pose
        end
    end
end
