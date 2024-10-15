# frozen_string_literal: true

require "rock_gazebo/syskit"
require "test/helpers"
using_task_library "rock_gazebo"

module OroGen
    describe rock_gazebo.WorldTask do
        run_simulated

        it { is_configurable }
    end

    describe rock_gazebo.ModelTask do
        run_simulated

        before do
            @use_sim_time = Conf.gazebo.use_sim_time?
        end

        after do
            Conf.gazebo.use_sim_time = @use_sim_time
        end

        it { is_configurable }

        it "sets use_sim_time to false if Conf.gazebo.use_sim_time is false" do
            Conf.gazebo.use_sim_time = false
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.ModelTask)
            refute task.orocos_task.use_sim_time
        end

        it "sets use_sim_time to true if Conf.gazebo.use_sim_time is true" do
            Conf.gazebo.use_sim_time = true
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.ModelTask)
            assert task.orocos_task.use_sim_time
        end

        describe "link export" do
            before do
                model = OroGen.rock_gazebo.ModelTask.with_dynamic_service(
                    "link_export", as: "test", port_name: "src2tgt"
                )
                robot_model = Syskit::Robot::RobotDefinition.new
                @test_link_dev = robot_model.device(
                    CommonModels::Devices::Gazebo::Link, as: "test", using: model
                )
                @model_with_frames =
                    model
                    .use_frames("test_source" => "src_frame",
                                "test_target" => "tgt_frame")
                    .with_arguments(test_dev: @test_link_dev)
                    .transformer { frames "src_frame", "tgt_frame" }
            end

            it "sets up the link export based on the instanciated "\
                "link_export services" do
                @test_link_dev.period(0.5)
                task = syskit_stub_deploy_and_configure(@model_with_frames)

                exports = task.orocos_task.exported_links
                assert_equal 1, exports.size

                export = exports.first
                assert_equal "src2tgt", export.port_name
                assert_equal "src_frame", export.source_frame
                assert_equal "tgt_frame", export.target_frame
                assert_equal "src_frame", export.source_link
                assert_equal "tgt_frame", export.target_link
                assert_equal 0.5, export.port_period.to_f
            end

            it "converts the exported link export in an exact way" do
                @test_link_dev.period(1.501)
                task = syskit_stub_deploy_and_configure(@model_with_frames)
                exports = task.properties.exported_links
                period = exports.first.port_period
                assert_equal 1, period.tv_sec
                assert_equal 501_000, period.tv_usec
            end
        end

        describe "joint export" do
            before do
                model = OroGen.rock_gazebo.ModelTask.with_dynamic_service(
                    "joint_export", as: "test", joint_names: %w[j1 j2]
                )
                robot_model = Syskit::Robot::RobotDefinition.new
                @test_joint_dev = robot_model.device(
                    CommonModels::Devices::Gazebo::Joint, as: "test", using: model
                )
            end

            it "configures a joint export based on the dynamic service info" do
                model = OroGen.rock_gazebo.ModelTask.with_dynamic_service(
                    "joint_export", as: "test", joint_names: %w[j1 j2]
                )
                robot_model = Syskit::Robot::RobotDefinition.new
                test_joint_dev = robot_model.device(
                    CommonModels::Devices::Gazebo::Joint, as: "test", using: model
                )
                task = syskit_stub_deploy_and_configure(test_joint_dev)

                exports = task.properties.exported_joints
                assert_equal 1, exports.size
                export = exports.first

                assert_equal "test_joints", export.port_name
                assert_equal %w[j1 j2], export.joints
                assert_equal "", export.prefix
                assert_equal 0, export.port_period.to_f
                assert_equal 0, export.ignore_joint_names
            end

            it "sets up the joint exports period based on the instanciated "\
                "joint_export services" do
                model = OroGen.rock_gazebo.ModelTask.with_dynamic_service(
                    "joint_export", as: "test", joint_names: %w[j1 j2]
                )
                robot_model = Syskit::Robot::RobotDefinition.new
                test_joint_dev = robot_model.device(
                    CommonModels::Devices::Gazebo::Joint, as: "test", using: model
                )
                test_joint_dev.period(0.5)
                task = syskit_stub_deploy_and_configure(test_joint_dev)

                exports = task.properties.exported_joints
                assert_equal 1, exports.size
                export = exports.first
                assert_equal 0.5, export.port_period.to_f
            end

            it "converts the exported link period in an exact way" do
                model = OroGen.rock_gazebo.ModelTask.with_dynamic_service(
                    "joint_export", as: "test", joint_names: %w[j1 j2]
                )
                robot_model = Syskit::Robot::RobotDefinition.new
                test_joint_dev = robot_model.device(
                    CommonModels::Devices::Gazebo::Joint, as: "test", using: model
                )
                test_joint_dev.period(1.501)
                task = syskit_stub_deploy_and_configure(test_joint_dev)
                exports = task.properties.exported_joints
                period = exports.first.port_period
                assert_equal 1, period.tv_sec
                assert_equal 501_000, period.tv_usec
            end

            it "passes the ignore_joint_commands flag" do
                task = deploy_and_configure_dynamic_service(
                    joint_names: %w[j1 j2], ignore_joint_names: true
                )

                exports = task.properties.exported_joints
                assert_equal 1, exports.first.ignore_joint_names
            end

            it "passes an empty position_offsets by default" do
                task = deploy_and_configure_dynamic_service(joint_names: %w[j1 j2])

                exports = task.properties.exported_joints
                assert exports.first.position_offsets.empty?
            end

            it "forwards an empty position_offsets" do
                task = deploy_and_configure_dynamic_service(
                    joint_names: %w[j1 j2],
                    position_offsets: []
                )

                exports = task.properties.exported_joints
                assert exports.first.position_offsets.empty?
            end

            it "forwards a position_offsets array of the same size than the joints" do
                task = deploy_and_configure_dynamic_service(
                    joint_names: %w[j1 j2],
                    position_offsets: [1, 2]
                )

                exports = task.properties.exported_joints
                assert_equal [1, 2], exports.first.position_offsets.to_a
            end

            it "validates the size of the position_offsets argument" do
                assert_raises(ArgumentError) do
                    OroGen.rock_gazebo.ModelTask.with_dynamic_service(
                        "joint_export", as: "test", joint_names: %w[j1 j2],
                                        position_offsets: [0]
                    )
                end
            end

            def deploy_and_configure_dynamic_service(**kw)
                model = OroGen.rock_gazebo.ModelTask.with_dynamic_service(
                    "joint_export", as: "test", **kw
                )

                robot_model = Syskit::Robot::RobotDefinition.new
                dev = robot_model.device(
                    CommonModels::Devices::Gazebo::Joint,
                    as: "test", using: model
                )
                syskit_stub_deploy_and_configure(dev)
            end
        end

        describe "submodel export" do
            def make_nested_model(sdf, period: 0.5)
                model = OroGen.rock_gazebo.ModelTask.with_dynamic_service(
                    "submodel_export", as: "test"
                )
                robot_model = Syskit::Robot::RobotDefinition.new
                root_model = SDF::Model.from_string(sdf)
                test_submodel_dev =
                    robot_model
                    .device(CommonModels::Devices::Gazebo::Model,
                            as: "test", using: model.test_srv)
                    .period(period)
                    .sdf(root_model.each_model.first)

                model.use_frames("test_source" => "src_frame",
                                 "test_target" => "tgt_frame")
                     .with_arguments(test_dev: test_submodel_dev)
                     .transformer { frames "src_frame", "tgt_frame" }
            end

            it "sets up the joint export" do
                model = make_nested_model(<<-SDF_MODEL)
                    <model name="m">
                        <model name="nested">
                            <link name="root" />
                            <link name="child" />
                            <joint name="root2child" type="revolute">
                                <parent>root</parent>
                                <child>child</child>
                            </joint>
                        </model>
                    </model>
                SDF_MODEL
                task = syskit_stub_deploy_and_configure(model)

                exports = task.properties.exported_joints
                assert_equal 1, exports.size
                export = exports.first
                assert_equal "test_joints", export.port_name
                assert_equal ["m::nested::root2child"], export.joints
                assert_equal "m::", export.prefix
                assert_equal 0.5, export.port_period.to_f
            end

            it "converts the period to the closest integer sec/usec pair" do
                model = make_nested_model(<<-SDF_MODEL, period: 1.501)
                    <model name="m">
                        <model name="nested">
                            <link name="root" />
                            <link name="child" />
                            <joint name="root2child" type="revolute">
                                <parent>root</parent>
                                <child>child</child>
                            </joint>
                        </model>
                    </model>
                SDF_MODEL
                task = syskit_stub_deploy_and_configure(model)

                exports = task.properties.exported_joints
                export = exports.first
                period = export.port_period
                assert_equal 1, period.tv_sec
                assert_equal 501_000, period.tv_usec
            end

            it "ignores fixed joints" do
                model = make_nested_model(<<-SDF_MODEL)
                    <model name="m">
                        <model name="nested">
                            <link name="root" />
                            <link name="child" />
                            <joint name="root2child" type="fixed">
                                <parent>root</parent>
                                <child>child</child>
                            </joint>
                        </model>
                    </model>
                SDF_MODEL
                task = syskit_stub_deploy_and_configure(model)

                export = task.properties.exported_joints.first
                assert_equal "test_joints", export.port_name
                assert_equal [], export.joints
                assert_equal "m::", export.prefix
                assert_equal 0.5, export.port_period.to_f
            end
        end

        it "uses a default period of zero" do
            model = OroGen.rock_gazebo.ModelTask.with_dynamic_service(
                "link_export", as: "test", port_name: "src2tgt"
            )
            robot_model = Syskit::Robot::RobotDefinition.new
            test_link_dev = robot_model.device(
                CommonModels::Devices::Gazebo::Link, as: "test", using: model
            )

            model_with_frames =
                model
                .use_frames("test_source" => "src_frame",
                            "test_target" => "tgt_frame")
                .with_arguments(test_dev: test_link_dev)
                .transformer { frames "src_frame", "tgt_frame" }
            task = syskit_stub_deploy_and_configure(model_with_frames)

            exports = task.properties.exported_links
            assert_equal Time.at(0), exports.first.port_period
        end
    end

    describe rock_gazebo.LaserScanTask do
        after do
            Conf.gazebo.use_sim_time = false
        end

        it "sets use_sim_time to false if Conf.gazebo.use_sim_time is false" do
            Conf.gazebo.use_sim_time = false
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.LaserScanTask)
            refute task.properties.use_sim_time
        end

        it "sets use_sim_time to true if Conf.gazebo.use_sim_time is true" do
            Conf.gazebo.use_sim_time = true
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.LaserScanTask)
            assert task.properties.use_sim_time
        end
    end

    describe rock_gazebo.ImuTask do
        after do
            Conf.gazebo.use_sim_time = false
        end

        it "sets use_sim_time to false if Conf.gazebo.use_sim_time is false" do
            Conf.gazebo.use_sim_time = false
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.ImuTask)
            refute task.orocos_task.use_sim_time
        end

        it "sets use_sim_time to true if Conf.gazebo.use_sim_time is true" do
            Conf.gazebo.use_sim_time = true
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.ImuTask)
            assert task.orocos_task.use_sim_time
        end
    end

    describe rock_gazebo.UnderwaterTask do
        it "sets use_sim_time to false if Conf.gazebo.use_sim_time is false" do
            Conf.gazebo.use_sim_time = false
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.UnderwaterTask)
            refute task.orocos_task.use_sim_time
        end

        it "sets use_sim_time to true if Conf.gazebo.use_sim_time is true" do
            Conf.gazebo.use_sim_time = true
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.UnderwaterTask)
            assert task.orocos_task.use_sim_time
        end
    end

    describe rock_gazebo.CameraTask do
        it "sets use_sim_time to false if Conf.gazebo.use_sim_time is false" do
            Conf.gazebo.use_sim_time = false
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.CameraTask)
            refute task.orocos_task.use_sim_time
        end

        it "sets use_sim_time to true if Conf.gazebo.use_sim_time is true" do
            Conf.gazebo.use_sim_time = true
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.CameraTask)
            assert task.orocos_task.use_sim_time
        end
    end

    describe rock_gazebo.GPSTask do
        before do
            stub_sdf
            Conf.sdf.world = SDF::World.from_string(
                "<world><spherical_coordinates>
                    <latitude_deg>48.8580</latitude_deg>
                    <longitude_deg>2.2946</longitude_deg>
                    <elevation>42</elevation>
                    </spherical_coordinates></world>"
            )
        end
        after do
            Conf.gazebo.use_sim_time = false
        end

        it "sets use_sim_time to false if Conf.gazebo.use_sim_time is false" do
            Conf.gazebo.use_sim_time = false
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.GPSTask)
            refute task.orocos_task.use_sim_time
        end

        it "sets use_sim_time to true if Conf.gazebo.use_sim_time is true" do
            Conf.gazebo.use_sim_time = true
            task = syskit_stub_deploy_and_configure(OroGen.rock_gazebo.GPSTask)
            assert task.orocos_task.use_sim_time
        end

        it "sets up the GPSTask latitude_origin and longitude_origin from "\
            "the spherical coordinates info in the SDF" do
            task = syskit_stub_deploy_and_configure OroGen.rock_gazebo.GPSTask
            assert_in_delta 48.8580 * Math::PI / 180,
                            task.orocos_task.latitude_origin.rad, 1e-6
            assert_in_delta 2.2946 * Math::PI / 180,
                            task.orocos_task.longitude_origin.rad, 1e-6
        end

        it "sets up the GPSTask origin property using the SDF global_origin" do
            task = syskit_stub_deploy_and_configure OroGen.rock_gazebo.GPSTask
            assert((Eigen::Vector3.new(5_411_910.38, 1_000_000 - 448_258.92, 42) -
                    task.orocos_task.nwu_origin).norm < 1,
                   "invalid nwu_origin set on task: #{task.orocos_task.nwu_origin.to_a}")
        end

        it "sets up the GPSTask UTM properties using the SDF UTM coordinates" do
            task = syskit_stub_deploy_and_configure OroGen.rock_gazebo.GPSTask
            assert_equal 31, task.orocos_task.utm_zone
            assert_equal true, task.orocos_task.utm_north
        end
    end
end
