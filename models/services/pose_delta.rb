import_types_from 'base'

module CommonModels
    module Services
        # Represents deltas in pose (i.e. pose change between two time steps).
        # Usually, a component that provides a PoseDelta will also provide
        # RelativePose.
        data_service_type 'PoseDelta' do
            output_port 'pose_delta_samples', '/base/samples/RigidBodyState'
        end
    end
end
