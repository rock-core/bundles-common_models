import_types_from 'base'
require 'models/services/control_loop'

CommonModels::Services::ControlLoop.declare \
    'JointsTrajectory', '/base/JointsTrajectory', '/base/samples/Joints'