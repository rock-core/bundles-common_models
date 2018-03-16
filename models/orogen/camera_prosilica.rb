require "common_models/models/blueprints/devices"
using_task_library "camera_prosilica"

class OroGen::CameraProsilica::Task
    driver_for Dev::Sensors::Cameras::Prosilica, :as => 'driver'
end

