import_types_from 'base'
require 'common_models/models/blueprints/pose'

module Base
    data_service_type "ImageConsumerSrv" do 
        input_port "frame","/base/samples/frame/Frame"
    end
    data_service_type 'IMUSensorsSrv' do
        output_port 'sensors', '/base/samples/IMUSensors'
    end
    autoload :CompensatedIMUSensorsSrv, 'common_models/models/blueprints/backwards/sensors.rb'
    autoload :CalibratedIMUSensorsSrv, 'common_models/models/blueprints/backwards/sensors.rb'
    autoload :ImageProviderSrv, 'common_models/models/blueprints/backwards/sensors.rb'
    autoload :LaserRangeFinderSrv, 'common_models/models/blueprints/backwards/sensors.rb'
    autoload :SonarScanProviderSrv, 'common_models/models/blueprints/backwards/sensors.rb'

    data_service_type 'StereoPairProviderSrv' do
        output_port 'images', ro_ptr('/base/samples/frame/FramePair')
    end

    data_service_type 'DistanceImageProviderSrv' do
        output_port 'distance_images', 'base/samples/DistanceImage'
    end

    data_service_type 'PointcloudProviderSrv' do
        output_port 'pointcloud', '/base/samples/Pointcloud'
    end
end

