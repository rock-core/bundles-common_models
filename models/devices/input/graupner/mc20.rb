require 'common_models/models/services/raw_input_command'

module Rock
    module Devices
        module Input
            module Graupner
                device_type 'Mc20' do
                    provides Rock::Services::RawInputCommand
                end
            end
        end
    end
end
