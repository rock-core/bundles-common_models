import_types_from 'base'

module CommonModels
    module Services
        # A provider for laser ranges
        data_service_type 'LaserScan' do
            output_port 'scans', '/base/samples/LaserScan'
        end
    end
end
