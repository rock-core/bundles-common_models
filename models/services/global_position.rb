require 'common_models/models/services/position'

module CommonModels
    module Services
        # Represents estimators that provide a position that is a best estimate of the
        # global position of the system. Because it is a best estimate, it can actually
        # jump
        #
        # It is typically a GPS
        data_service_type 'GlobalPosition' do
            provides Position
        end
    end
end
