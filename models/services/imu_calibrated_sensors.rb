import_types_from 'base'

module CommonModels
    module Services
        data_service_type 'IMUCalibratedSensors' do
            output_port 'calibrated_sensors', '/base/samples/IMUSensors'
        end
    end
end
