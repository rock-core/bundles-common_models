require 'common_models/models/blueprints/devices'
class OroGen::ServoDynamixel::Task
    driver_for Dev::Actuators::Dynamixel, :as => 'driver'

    orogen_model.find_port('command').multiplexes

    transformer do
        frames "lower", "upper"
        transform_output "transforms", "lower" => "upper"
    end
end
