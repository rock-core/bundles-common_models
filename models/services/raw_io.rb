import_types_from 'iodrivers_base'

module CommonModels
    module Services
        data_service_type 'RawIO' do
            input_port 'raw_in', '/iodrivers_base/RawPacket'
            output_port 'raw_out', '/iodrivers_base/RawPacket'
        end
    end
end
