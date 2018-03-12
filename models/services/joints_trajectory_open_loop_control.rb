import_types_from 'base'
require 'models/services/control_loop'

CommonModels::Services::ControlLoop.declare_open_loop \
    'JointsTrajectory', '/base/JointsTrajectory'