import_types_from 'base'

module CommonModels
    module Services
        # Execution of a set of trajectories
        data_service_type 'TrajectoryExecution' do
            input_port 'trajectory', '/std/vector</base/Trajectory>'
        end
    end
end
