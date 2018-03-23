import_types_from 'base'
require 'common_models/models/services/control_loop'

CommonModels::Services::ControlLoop.declare \
    'Joints', '/base/commands/Joints', '/base/samples/Joints'

