import_types_from 'base'

module CommonModels
    module Services
        # Provider of IMU raw sensor data
        #
        # Raw IMU sensor data, that is gyros and accelerometers.
        #
        # @see IMUCompensatedSensors
        # @see IMUCalibratedSensors
        data_service_type 'IMURawSensors' do
            output_port 'raw_sensors', '/base/samples/IMUSensors'
        end
    end
end
