require 'common_models/models/services/sonar_beam'

module Rock
    module Devices
        module Sonar
            module Tritech
                device_type 'Micron' do
                    provides Rock::Services::SonarBeam
                end
            end
        end
    end
end
