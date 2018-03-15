require 'common_models/models/services/raw_input_command'

module Rock
    module Devices
        module Input
            device_type 'Joystick' do
                provides Rock::Services::RawInputCommand
            end
        end
    end
end

