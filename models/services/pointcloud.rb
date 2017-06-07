import_types_from 'base'

module CommonModels
    module Services
        data_service_type 'Pointcloud' do
            output_port 'point_cloud', '/base/samples/Pointcloud'
        end
    end
end
