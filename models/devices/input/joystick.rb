require 'common_models/models/services/raw_input_command'

module CommonModels
    module Devices
        module Input
            device_type 'Joystick' do
                provides CommonModels::Services::RawInputCommand
            end
        end
    end
end

