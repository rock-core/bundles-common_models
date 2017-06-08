import_types_from 'base'

module CommonModels
    module Services
        # Provider of a point cloud measurement
        data_service_type 'Pointcloud' do
            output_port 'point_cloud', '/base/samples/Pointcloud'
        end
    end
end
