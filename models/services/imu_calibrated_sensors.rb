import_types_from 'base'

module CommonModels
    module Services
        # Provider of IMU calibrated sensor data
        #
        # IMU sensor data includes gyros and accelerometers. When providing this
        # service, the sensors are expected to be calibrated, i.e. to be free of
        # offset and scale factors.
        #
        # @see IMURawSensors
        # @see IMUCompensatedSensors
        data_service_type 'IMUCalibratedSensors' do
            output_port 'calibrated_sensors', '/base/samples/IMUSensors'
        end
    end
end
