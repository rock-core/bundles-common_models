import_types_from 'controldev'

module CommonModels
    module Services
        # Representation of the raw input from a control device (joystick, ...)
        data_service_type 'RawInputCommand' do
            output_port 'commands', '/controldev/RawCommand'
        end
    end
end
