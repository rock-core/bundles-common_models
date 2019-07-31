# frozen_string_literal: true

require 'common_models/models/services/joints_control_loop'
require 'common_models/models/services/transformation'
require 'common_models/models/devices/gazebo'

## Double negation is needed to convert objects to boolean when writing to properties
# rubocop:disable Style/DoubleNegation

class OroGen::RockGazebo::WorldTask
    # Customizes the configuration step.
    #
    # The orocos task is available from orocos_task
    #
    # The call to super here applies the configuration on the orocos task. If
    # you need to override properties, do it afterwards
    #
    # def configure
    #     super
    # end
end

# Handling of a gazebo model on the CommonModels side
#
# ModelTasks are {CommonModels::Services::JointsControlledSystem}, that is they report
# the state of their joints, and accept joint commands
#
# They also can export transformations between two arbitrary links. This is
# modelled on the syskit side by a dynamic service. One first instanciates the
# service with e.g.
#
# @example
#   model = OroGen::RockGazebo::ModelTask.specialize
#   model.require_dynamic_service 'link_export, as: 'new_service_name',
#       port_name: 'whatever_you_want_but_uses_the_service_name_by_default"
#
# This creates the relevant port (under 'port_name'), and declares an associated
# transformation between the 'new_service_name_source' frame and the
# 'new_service_name_target' frame. One therefore deploys the generated component
# with e.g.
#
# @example
#   model.use_frames(
#     'new_service_name_source' => 'world',
#     'new_service_name_target' => 'camera')
#
# Note that in most cases you won't have to access this interface directly, the
# rock_gazebo plugin does it for you through a high-level API on the profiles.
class OroGen::RockGazebo::ModelTask
    driver_for CommonModels::Devices::Gazebo::RootModel, as: 'model'

    # @api private
    #
    # Common implementation of the two dynamic services (Link and Model)
    def self.common_dynamic_link_export(_context, name, port_name = name, options)
        port_name      = options.fetch(:port_name, port_name)
        frame_basename = options.fetch(:frame_basename, name)
        nans = [Float::NAN] * 9
        options[:cov_position]    ||= Types.base.Matrix3d.new(data: nans.dup)
        options[:cov_orientation] ||= Types.base.Matrix3d.new(data: nans.dup)
        options[:cov_velocity]    ||= Types.base.Matrix3d.new(data: nans.dup)
        [port_name, frame_basename]
    end

    # Declare a dynamic service for the link export feature
    #
    # One uses it by first require'ing
    dynamic_service CommonModels::Devices::Gazebo::Link, as: 'link_export' do
        name = self.name
        port_name, frame_basename =
            OroGen::RockGazebo::ModelTask
            .common_dynamic_link_export(self, name, options)
        driver_for CommonModels::Devices::Gazebo::Link,
                   'link_state_samples' => port_name,
                   'wrench_samples' => "#{port_name}_wrench",
                   'acceleration_samples' => "#{port_name}_acceleration"
        component_model.transformer do
            transform_output(
                port_name, "#{frame_basename}_source" => "#{frame_basename}_target"
            )
        end
    end

    # Declare a dynamic service that provides an interface to a submodel
    #
    # It's essentially a Link with the original model joints. The joint stuff is
    # either-or, that is it is currently impossible to use two model/submodels
    # at the same time.
    dynamic_service CommonModels::Devices::Gazebo::Model, as: 'submodel_export' do
        name = self.name
        OroGen::RockGazebo::ModelTask.common_dynamic_link_export(
            self, name, options.merge!(port_name: "#{name}_pose_samples")
        )
        driver_for CommonModels::Devices::Gazebo::Model,
                   'joints_cmd' => "#{name}_joints_cmd",
                   'joints_status' => "#{name}_joints_samples"
    end

    transformer do
        transform_output 'pose_samples', 'model' => 'world'
    end

    def period_to_time(period)
        if period
            period_us = (period * 1_000_000).round
            Time.at(period_us / 1_000_000, period_us % 1_000_000, :usec)
        else
            Time.at(0)
        end
    end

    def create_link_export(link_srv)
        # Find the task port that on which the service port is mapped
        task_port = link_srv.link_state_samples_port.to_component_port
        # And get the relevant transformer information
        unless (transform = find_transform_of_port(task_port))
            raise ArgumentError, "cannot find the transform information for #{task_port}"
        end

        if !transform.from || !transform.to
            model_transform = self.class.find_transform_of_port(task_port)
            raise ArgumentError, 'you did not select the frames for '\
                                    "#{model_transform.from} or #{model_transform.to}, "\
                                    "needed for #{link_srv.name}"
        end
        device = find_device_attached_to(link_srv)

        Types.rock_gazebo.LinkExport.new(
            port_name: task_port.name,
            source_link: transform.from,
            target_link: transform.to,
            source_frame: transform.from,
            target_frame: transform.to,
            port_period: period_to_time(device.period),
            cov_position: link_srv.model.dynamic_service_options[:cov_position],
            cov_orientation: link_srv.model.dynamic_service_options[:cov_orientation],
            cov_velocity: link_srv.model.dynamic_service_options[:cov_velocity]
        )
    end

    def create_joint_export(model_srv)
        device = find_device_attached_to(model_srv)

        # Find the root model
        sdf_model      = device.sdf
        sdf_root_model = sdf_model
        while sdf_root_model&.parent.kind_of?(SDF::Model)
            sdf_root_model = sdf_root_model.parent
        end

        # The list of joint names
        joint_names = sdf_model.each_joint.map do |j|
            next if j.type == 'fixed'

            j.full_name(root: sdf_root_model.parent)
        end.compact

        if sdf_model != sdf_root_model
            prefix = "#{sdf_model.parent.full_name(root: sdf_root_model.parent)}::"
        end

        Types.rock_gazebo.JointExport.new(
            port_name: "#{model_srv.name}_joints",
            joints: joint_names,
            prefix: prefix || '',
            port_period: period_to_time(device.period)
        )
    end

    def configure
        super

        link_exports  = []
        joint_exports = []

        # Setup the link export based on the instanciated link_export services
        # The source/target information is stored in the transformer
        each_required_dynamic_service do |srv|
            if srv.fullfills?(CommonModels::Devices::Gazebo::Link)
                link_exports << create_link_export(
                    srv.as(CommonModels::Devices::Gazebo::Link)
                )
            end
            if srv.fullfills?(CommonModels::Devices::Gazebo::Model)
                joint_exports << create_joint_export(srv)
            end
        end

        properties.use_sim_time = !!Conf.gazebo.use_sim_time?
        properties.exported_links  = link_exports
        properties.exported_joints = joint_exports
    end

    stub do
        def configure(*)
            super
            model.each_output_port do |p|
                create_output_port(p.name, p.type) unless has_port?(p.name)
            end
        end
    end
end

class OroGen::RockGazebo::LaserScanTask
    driver_for CommonModels::Devices::Gazebo::Ray, as: 'sensor'

    transformer do
        frames 'sensor'
        associate_ports_to_frame 'laser_scan_samples', 'sensor'
    end

    def configure
        super
        properties.use_sim_time = !!Conf.gazebo.use_sim_time?
    end
end

class OroGen::RockGazebo::ImuTask
    driver_for CommonModels::Devices::Gazebo::Imu, as: 'sensor'

    transformer do
        frames 'sensor', 'inertial'
        associate_ports_to_transform 'orientation_samples', 'sensor' => 'inertial'
        associate_ports_to_frame 'imu_samples', 'sensor'
    end

    def configure
        super
        properties.use_sim_time = !!Conf.gazebo.use_sim_time?
    end
end

class OroGen::RockGazebo::ThrusterTask
    driver_for CommonModels::Devices::Gazebo::Thruster, as: 'thruster'

    def configure
        super
        properties.use_sim_time = !!Conf.gazebo.use_sim_time?
    end
end

class OroGen::RockGazebo::UnderwaterTask
    driver_for CommonModels::Devices::Gazebo::Underwater, as: 'underwater'

    def configure
        super
        properties.use_sim_time = !!Conf.gazebo.use_sim_time?
    end
end

class OroGen::RockGazebo::CameraTask
    driver_for CommonModels::Devices::Gazebo::Camera, as: 'sensor'

    transformer do
        frames 'sensor'
        associate_ports_to_frame 'frame', 'sensor'
    end

    def configure
        super
        properties.use_sim_time = !!Conf.gazebo.use_sim_time?
    end
end

class OroGen::RockGazebo::GPSTask
    driver_for CommonModels::Devices::Gazebo::GPS, as: 'gps'

    transformer do
        frames 'gps', 'nwu', 'utm'
        associate_ports_to_transform 'position_samples', 'gps' => 'nwu'
        associate_ports_to_transform 'utm_samples', 'gps' => 'utm'
    end

    def configure
        super
        properties.use_sim_time = !!Conf.gazebo.use_sim_time?
        properties.latitude_origin = Types.base.Angle.new(
            rad: Conf.sdf.world.spherical_coordinates.latitude_deg * Math::PI / 180
        )
        properties.longitude_origin = Types.base.Angle.new(
            rad: Conf.sdf.world.spherical_coordinates.longitude_deg * Math::PI / 180
        )
        properties.nwu_origin = Conf.sdf.global_origin
        properties.utm_zone   = Conf.sdf.utm_zone
        properties.utm_north  = !!Conf.sdf.utm_north?
    end
end

# rubocop:enable Style/DoubleNegation
