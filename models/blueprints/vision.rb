require 'common_models/models/blueprints/sensors'
using_task_library 'stereo'

module ImageProcessing
    # Integration of the stereo processing task
    class Stereo < Syskit::Composition
        add ::Stereo::Task, :as => 'processing'

        add Base::ImageProviderSrv, :as => 'left'
        add Base::ImageProviderSrv, :as => 'right'

        left_child.frame_port.connect_to processing_child.left_frame_port
        right_child.frame_port.connect_to processing_child.right_frame_port

        export processing_child.distance_frame_port
        provides Base::DistanceImageProviderSrv, :as => 'distance_image'
    end
end

