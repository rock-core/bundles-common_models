import_types_from 'controldev'

module CommonModels
    module Services
        data_service_type 'RawInputCommand' do
            output_port 'commands', '/controldev/RawCommand'
        end
    end
end
