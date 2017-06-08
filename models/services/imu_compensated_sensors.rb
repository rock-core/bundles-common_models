import_types_from 'base'

module CommonModels
    module Services
        # Provider of IMU compensated sensor data
        #
        # IMU sensor data includes gyros and accelerometers. When providing this
        # service, the sensors are expected to be compensated, i.e. to have
        # random walk and bias instability corrected.
        #
        # @see IMURawSensors
        # @see IMUCalibratedSensors
        data_service_type 'IMUCompensatedSensors' do
            output_port 'compensated_sensors', '/base/samples/IMUSensors'
        end
    end
end
