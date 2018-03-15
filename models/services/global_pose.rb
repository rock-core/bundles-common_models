import_types_from 'base'
require 'common_models/models/services/pose'

module Rock
    module Services
        # Represents estimators that provide a pose that is a best estimate of the
        # global pose of the system. Because it is a best estimate, it can actually
        # jump
        #
        # It is typically a pose estimator which fuses a global position measurement
        # such as GPS
        data_service_type 'GlobalPose' do
            provides GlobalPosition
            provides Pose
        end
    end
end
