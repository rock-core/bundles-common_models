require 'common_models/models/blueprints/control'

class OroGen::Skid4Control::SimpleController
    provides Base::ActuatorControllerSrv, :as => 'controller'
    provides Base::Motion2DControlledSystemSrv, :as => 'controlled_system'
end

using_task_library 'controldev'
class OroGen::Skid4Control::FourWheelController
    provides Base::ActuatorControllerSrv, :as => 'controller'
    provides Base::FourWheelControlledSystemSrv, :as => 'controlled_system'
end

class OroGen::Skid4Control::ConstantSpeedController
    provides Base::ActuatorControllerSrv, :as => 'controller'
    provides Base::Motion2DControlledSystemSrv, :as => 'controlled_system'
end
