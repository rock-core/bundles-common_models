require 'common_models/models/services/global_position'

module Rock
    module Devices
        module GPS
            device_type 'MB500' do
                provides Services::GlobalPosition
            end
        end
    end
end
