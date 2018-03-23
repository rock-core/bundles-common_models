require 'common_models/backward_module_name'
Syskit.warn "The services from the Base:: module that were defined in models/blueprints/pose are now defined under models/services/, and have been renamed to match the new Syskit naming conventions"
module Base
    backward_compatible_constant :PositionSrv         , "Rock::Services::Position"         , 'common_models/models/services/position'
    backward_compatible_constant :RotationSrv         , "Rock::Services::Rotation"         , 'common_models/models/services/rotation'
    backward_compatible_constant :OrientationSrv      , "Rock::Services::Orientation"      , 'common_models/models/services/orientation'
    backward_compatible_constant :ZProviderSrv        , "Rock::Services::ZProvider"        , 'common_models/models/services/z_provider'
    backward_compatible_constant :OrientationWithZSrv , "Rock::Services::OrientationWithZ" , 'common_models/models/services/orientation_with_z'
    backward_compatible_constant :PoseSrv             , "Rock::Services::Pose"             , 'common_models/models/services/pose'
    backward_compatible_constant :TransformationSrv   , "Rock::Services::Transformation"   , 'common_models/models/services/transformation'
    backward_compatible_constant :GlobalPoseSrv       , "Rock::Services::GlobalPose"       , 'common_models/models/services/global_pose'
    backward_compatible_constant :RelativePoseSrv     , "Rock::Services::RelativePose"     , 'common_models/models/services/relative_pose'
    backward_compatible_constant :PoseDeltaSrv        , "Rock::Services::PoseDelta"        , 'common_models/models/services/pose_delta'
    backward_compatible_constant :VelocitySrv         , "Rock::Services::Velocity"         , 'common_models/models/services/velocity'
    backward_compatible_constant :GroundDistanceSrv   , "Rock::Services::GroundDistance"   , 'common_models/models/services/ground_distance'
end
