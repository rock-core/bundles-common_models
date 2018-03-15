import_types_from 'base'
require 'common_models/models/services/control_loop'
Rock::Services::ControlLoop.declare_open_loop \
    'Motion2D', '/base/commands/Motion2D'

