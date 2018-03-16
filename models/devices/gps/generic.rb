require 'common_models/models/services/position'

module CommonModels
    module Devices
        module GPS
            device_type 'Generic' do
                provides Services::Position
            end
        end
    end
end
