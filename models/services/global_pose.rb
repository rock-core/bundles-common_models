import_types_from 'base'
require 'common_models/models/services/pose'
require 'common_models/models/services/global_position'

module CommonModels
    module Services
        # Represents estimators that provide a pose that is a best estimate of the
        # global pose of the system. Because it is a best estimate, it can actually
        # jump
        #
        # It is typically a pose estimator which fuses a global position measurement
        # such as GPS
        data_service_type 'GlobalPose' do
            provides Pose
            provides GlobalPosition, 'position_samples' => 'pose_samples'
        end
    end
end
