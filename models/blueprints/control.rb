module Base
    autoload :ControllerSrv, 'common_models/models/blueprints/backwards/control'
    autoload :ControlledSystemSrvSrv, 'common_models/models/blueprints/backwards/control'
    autoload :ControlLoop, 'common_models/models/blueprints/backwards/control'

    autoload :ActuatorControlledSystemSrv, 'common_models/models/blueprints/backwards/control'
    autoload :ActuatorControllerSrv, 'common_models/models/blueprints/backwards/control'
    autoload :ActuatorStatusSrv, 'common_models/models/blueprints/backwards/control'
    autoload :ActuatorCommandSrv, 'common_models/models/blueprints/backwards/control'
    autoload :ActuatorCommandConsumerSrv, 'common_models/models/blueprints/backwards/control'

    autoload :JointsControlledSystemSrv, 'common_models/models/blueprints/backwards/control'
    autoload :JointsControllerSrv, 'common_models/models/blueprints/backwards/control'
    autoload :JointsStatusSrv, 'common_models/models/blueprints/backwards/control'
    autoload :JointsCommandSrv, 'common_models/models/blueprints/backwards/control'
    autoload :JointsCommandConsumerSrv, 'common_models/models/blueprints/backwards/control'

    autoload :Motion2DControlledSystemSrv, 'common_models/models/blueprints/backwards/control'
    autoload :Motion2DControllerSrv, 'common_models/models/blueprints/backwards/control'
    autoload :Motion2DStatusSrv, 'common_models/models/blueprints/backwards/control'
    autoload :Motion2DCommandSrv, 'common_models/models/blueprints/backwards/control'
    autoload :Motion2DCommandConsumerSrv, 'common_models/models/blueprints/backwards/control'
end

