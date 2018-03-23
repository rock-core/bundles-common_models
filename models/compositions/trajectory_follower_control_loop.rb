require 'common_models/models/compositions/motion2d_control_loop'
require 'common_models/models/services/pose'
require 'common_models/models/services/trajectory_execution'
using_task_library 'trajectory_follower'

module CommonModels
    module Compositions
        ControlLoop.specialize \
            ControlLoop.controller_child => OroGen::TrajectoryFollower::Task,
            ControlLoop.controlled_system_child => Services::Motion2DOpenLoopControlledSystem do

            add Services::Pose, as: 'pose'
            pose_child.connect_to controller_child
            export controller_child.trajectory_port

            provides Services::TrajectoryExecution, as: 'trajectory_execution'
        end
    end
end

