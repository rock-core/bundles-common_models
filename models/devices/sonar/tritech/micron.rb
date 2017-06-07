require 'common_models/models/services/sonar_beam'

module CommonModels
    module Devices
        module Sonar
            module Tritech
                device_type 'Micron' do
                    provides CommonModels::Services::SonarBeam
                end
            end
        end
    end
end
