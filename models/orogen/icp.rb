require 'models/blueprints/pose'

class OroGen::Icp::Task
    find_output_port('pose_samples').
        triggered_once_per_update
    worstcase_processing_time 1

    # Additional configuration for the transformer's automatic configuration
    transformer do
        transform_input "initial_pose_estimate", "body" => "world"
        transform_output "pose_samples", "body" => "world"
        associate_frame_to_ports "laser", "scan_samples"
    end

    def configure
        super
        orogen_task.environment_path = Conf.pointcloud_map_path
    end
end

class OroGen::Icp::Relocalization < Syskit::Composition
    add Srv::RelativePose, :as => 'relative_pose'
    add Srv::LaserRangeFinder, :as => 'laser_range_finder'

    event :triggered
    event :done
    add(Icp::Task, :as => 'icp').
        use_conf('default', 'relocalization')

    laser_range_finder_child.scans_port.connect_to icp_child.scan_samples_port

    attr_reader :result
    attr_reader :position
    attr_reader :yaw_bias

    argument :initial_pose, :default => from_state.pose

    event :start do |context|
        @result_reader = data_reader('icp', 'pose_samples')
        @orientation_reader = data_reader('relative_pose', 'pose_samples')
        @pose_writer = data_writer('icp', 'initial_pose_estimate', :type => :buffer, :size => 2)
        @pose_sample = @pose_writer.new_sample
        @pose_sample.zero!
        @pose_sample.cov_position.data[0] = 1
        @pose_sample.cov_position.data[4] = 1
        @pose_sample.cov_position.data[8] = 1
        @pose_sample.cov_orientation.data[0] = 0.07
        @pose_sample.cov_orientation.data[4] = 0.07
        @pose_sample.cov_orientation.data[8] = 0.07
        [:position, :cov_position, :orientation, :cov_orientation].each do |field|
            if initial_pose.respond_to?(field)
                @pose_sample.send("#{field}=", initial_pose.send(field))
            end
        end

        emit :start
    end

    on :done do |event|
        if !initial_estimate?
            pose = @result_reader.read
            if !pose
                emit :failed_initial_estimate
            else
                @pose_sample = pose
                emit :initial_estimate
            end
        end
    end

    # Emitted when the ICP produced one result
    event :initial_estimate
    # Emitted if the first ICP run failed to converge
    event :failed_initial_estimate
    forward :failed_initial_estimate => :failed

    # We then reconfigure it "behind the scenes" into UNIFORM search mode and
    # feed it the estimate that it gave us
    on :initial_estimate do |context|
        Robot.info "relocalization: found initial estimate"
        Robot.info "#{@pose_sample.position}"
        Robot.info "#{@pose_sample.cov_position.data[0]}, #{@pose_sample.cov_position.data[4]}, #{@pose_sample.cov_position.data[8]}"
        icp_task = child_from_role('icp').orogen_task
        Orocos.conf.apply(icp_task, ['default', 'uniform_sampling'], true)
        @refinement = icp_task.sendop(:calculateLastPointCloud, @pose_sample, 0)
    end

    poll do
        if initial_estimate?
            status, _ = @refinement.collect_if_done
            if status == Orocos::SEND_SUCCESS
                sleep 0.1 # wait for the result to be available on the port. Should be simply returned by the operation
                @result = @result_reader.read_new
                if @result
                    Robot.info "found full relocalization solution"
                else
                    @result = @pose_sample
                    Robot.info "using initial estimate as solution"
                end

                @position = @result.position
                @yaw_bias = @result.orientation.yaw - @measured_yaw
                emit :success
            end
        elsif !triggered?
            icp_task = child_from_role('icp')

            if (pose = @orientation_reader.read) && icp_task.running?
                @measured_yaw = pose.orientation.yaw
                @initial_odometry_pose ||= pose

                @pose_sample.time = Time.now
                if !initial_pose.respond_to?(:orientation)
                    if initial_pose.respond_to?(:yaw_bias)
                        @pose_sample.orientation = Types::Base::Orientation.from_yaw(initial_pose.yaw_bias) * pose.orientation
                        # @pose_sample.cov_orientation = pose.cov_orientation
                    else
                        @pose_sample.orientation = pose.orientation
                        # @pose_sample.cov_orientation = pose.cov_orientation
                    end
                end

                d = (@initial_odometry_pose.position - pose.position).norm
                Robot.info "moved %.2f m so far" % [d]
		Robot.info "writing pose: #{@pose_sample.position.to_a.inspect}"
                @pose_writer.write(@pose_sample)
            end
        end
    end
end

