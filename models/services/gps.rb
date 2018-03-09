import_types_from 'gps_base'

module CommonModels
    module Services
        data_service_type 'GPS' do
            output_port 'solution', 'gps_base/Solution'
        end
    end
end
