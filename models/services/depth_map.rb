# frozen_string_literal: true

module CommonModels
    module Services #:nodoc:
        # A provider for depth map samples
        data_service_type "DepthMap" do
            output_port "depth_map", "/base/samples/DepthMap"
        end
    end
end
