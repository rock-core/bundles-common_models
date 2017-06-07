import_types_from 'base'

module CommonModels
    module Services
        data_service_type 'IMURawSensors' do
            output_port 'raw_sensors', '/base/samples/IMUSensors'
        end
    end
end
