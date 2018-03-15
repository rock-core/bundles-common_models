require 'common_models/models/services/position'

module Rock
    module Services
        data_service_type 'GlobalPosition' do
            provides Position
        end
    end
end
