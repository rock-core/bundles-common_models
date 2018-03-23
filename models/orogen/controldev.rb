require 'common_models/models/devices/input/joystick'
require 'common_models/models/devices/input/graupner/mc20'

class OroGen::Controldev::JoystickTask
    driver_for CommonModels::Devices::Input::Joystick, as: 'driver'
end

class OroGen::Controldev::GraupnerMC20Task
    driver_for CommonModels::Devices::Input::Graupner::Mc20, as: 'driver'
end
