require 'common_models/models/devices/gps/mb500'
require 'common_models/models/devices/gps/generic'

class OroGen::Gps::BaseTask
    def configure
        super

        if Conf.utm_local_origin?
            orocos_task.origin = Conf.utm_local_origin
        end
    end
end

class OroGen::Gps::MB500Task
    driver_for CommonModels::Devices::GPS::MB500, as: 'driver'
end

class OroGen::Gps::GPSDTask
    driver_for CommonModels::Devices::GPS::Generic, as: 'driver'
end
