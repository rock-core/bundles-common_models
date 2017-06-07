require 'common_models/backward_module_name'
Syskit.warn "The services from the Base:: module that were defined in models/blueprints/pose are now defined under models/services/, and have been renamed to match the new Syskit naming conventions"
module Base
    backward_compatible_constant :PositionSrv         , "Rock::Services::Position"         , 'models/services/position'
    backward_compatible_constant :RotationSrv         , "Rock::Services::Rotation"         , 'models/services/rotation'
    backward_compatible_constant :OrientationSrv      , "Rock::Services::Orientation"      , 'models/services/orientation'
    backward_compatible_constant :ZProviderSrv        , "Rock::Services::ZProvider"        , 'models/services/z_provider'
    backward_compatible_constant :OrientationWithZSrv , "Rock::Services::OrientationWithZ" , 'models/services/orientation_with_z'
    backward_compatible_constant :PoseSrv             , "Rock::Services::Pose"             , 'models/services/pose'
    backward_compatible_constant :TransformationSrv   , "Rock::Services::Transformation"   , 'models/services/transformation'
    backward_compatible_constant :GlobalPoseSrv       , "Rock::Services::GlobalPose"       , 'models/services/global_pose'
    backward_compatible_constant :RelativePoseSrv     , "Rock::Services::RelativePose"     , 'models/services/relative_pose'
    backward_compatible_constant :PoseDeltaSrv        , "Rock::Services::PoseDelta"        , 'models/services/pose_delta'
    backward_compatible_constant :VelocitySrv         , "Rock::Services::Velocity"         , 'models/services/velocity'
    backward_compatible_constant :GroundDistanceSrv   , "Rock::Services::GroundDistance"   , 'models/services/ground_distance'
end
