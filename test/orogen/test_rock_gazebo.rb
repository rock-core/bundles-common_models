# frozen_string_literal: true

require 'rock_gazebo/syskit'
require 'test/helpers'
using_task_library 'rock_gazebo'

module OroGen
    module RockGazebo
        describe WorldTask do
            run_simulated

            it { is_configurable }
        end

        describe ModelTask do
            run_simulated

            after do
                Conf.gazebo.use_sim_time = false
            end

            it { is_configurable }

            it 'sets use_sim_time to false if Conf.gazebo.use_sim_time is false' do
                task = syskit_stub_deploy_and_configure(ModelTask)
                refute task.orocos_task.use_sim_time
            end

            it 'sets use_sim_time to true if Conf.gazebo.use_sim_time is true' do
                Conf.gazebo.use_sim_time = true
                task = syskit_stub_deploy_and_configure(ModelTask)
                assert task.orocos_task.use_sim_time
            end

            describe 'link export' do
                before do
                    model = ModelTask.specialize
                    model.require_dynamic_service(
                        'link_export', as: 'test', port_name: 'src2tgt'
                    )
                    robot_model = Syskit::Robot::RobotDefinition.new
                    @test_link_dev = robot_model
                                     .device CommonModels::Devices::Gazebo::Link,
                                             as: 'test', using: model
                    @model_with_frames =
                        model
                        .use_frames('test_source' => 'src_frame',
                                    'test_target' => 'tgt_frame')
                        .with_arguments(test_dev: @test_link_dev)
                        .transformer { frames 'src_frame', 'tgt_frame' }
                end

                it 'sets up the link export based on the instanciated '\
                   'link_export services' do
                    @test_link_dev.period(0.5)
                    task = syskit_stub_deploy_and_configure(@model_with_frames)

                    exports = task.orocos_task.exported_links
                    assert_equal 1, exports.size

                    export = exports.first
                    assert_equal 'src2tgt', export.port_name
                    assert_equal 'src_frame', export.source_frame
                    assert_equal 'tgt_frame', export.target_frame
                    assert_equal 'src_frame', export.source_link
                    assert_equal 'tgt_frame', export.target_link
                    assert_equal 0.5, export.port_period.to_f
                end

                it 'converts the exported link export in an exact way' do
                    @test_link_dev.period(1.501)
                    task = syskit_stub_deploy_and_configure(@model_with_frames)
                    exports = task.orocos_task.exported_links
                    period = exports.first.port_period
                    assert_equal 1, period.tv_sec
                    assert_equal 501_000, period.tv_usec
                end
            end

            describe 'submodel export' do
                def make_nested_model(sdf, period: 0.5)
                    model = ModelTask.specialize
                    model.require_dynamic_service 'submodel_export', as: 'test'
                    robot_model = Syskit::Robot::RobotDefinition.new
                    root_model = SDF::Model.from_string(sdf)
                    test_submodel_dev =
                        robot_model
                        .device(CommonModels::Devices::Gazebo::Model,
                                as: 'test', using: model.test_srv)
                        .period(period)
                        .sdf(root_model.each_model.first)

                    model.use_frames('test_source' => 'src_frame',
                                     'test_target' => 'tgt_frame')
                         .with_arguments(test_dev: test_submodel_dev)
                         .transformer { frames 'src_frame', 'tgt_frame' }
                end

                it 'sets up the joint export' do
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

                    exports = task.orocos_task.exported_joints
                    assert_equal 1, exports.size
                    export = exports.first
                    assert_equal 'test_joints', export.port_name
                    assert_equal ['m::nested::root2child'], export.joints
                    assert_equal 'm::', export.prefix
                    assert_equal 0.5, export.port_period.to_f
                end

                it 'converts the period to the closest integer sec/usec pair' do
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

                    exports = task.orocos_task.exported_joints
                    export = exports.first
                    period = export.port_period
                    assert_equal 1, period.tv_sec
                    assert_equal 501_000, period.tv_usec
                end

                it 'ignores fixed joints' do
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

                    export = task.orocos_task.exported_joints.first
                    assert_equal 'test_joints', export.port_name
                    assert_equal [], export.joints
                    assert_equal 'm::', export.prefix
                    assert_equal 0.5, export.port_period.to_f
                end
            end

            it 'uses a default period of zero' do
                model = ModelTask.specialize
                model.require_dynamic_service(
                    'link_export', as: 'test', port_name: 'src2tgt'
                )
                robot_model = Syskit::Robot::RobotDefinition.new
                test_link_dev = robot_model.device CommonModels::Devices::Gazebo::Link,
                                                   as: 'test', using: model

                model_with_frames =
                    model
                    .use_frames('test_source' => 'src_frame',
                                'test_target' => 'tgt_frame')
                    .with_arguments(test_dev: test_link_dev)
                    .transformer { frames 'src_frame', 'tgt_frame' }
                task = syskit_stub_deploy_and_configure(model_with_frames)

                exports = task.orocos_task.exported_links
                assert_equal Time.at(0), exports.first.port_period
            end
        end

        describe LaserScanTask do
            after do
                Conf.gazebo.use_sim_time = false
            end

            it 'sets use_sim_time to false if Conf.gazebo.use_sim_time is false' do
                Conf.gazebo.use_sim_time = false
                task = syskit_stub_deploy_and_configure(LaserScanTask)
                refute task.orocos_task.use_sim_time
            end

            it 'sets use_sim_time to true if Conf.gazebo.use_sim_time is true' do
                Conf.gazebo.use_sim_time = true
                task = syskit_stub_deploy_and_configure(LaserScanTask)
                assert task.orocos_task.use_sim_time
            end
        end

        describe ImuTask do
            after do
                Conf.gazebo.use_sim_time = false
            end

            it 'sets use_sim_time to false if Conf.gazebo.use_sim_time is false' do
                Conf.gazebo.use_sim_time = false
                task = syskit_stub_deploy_and_configure(ImuTask)
                refute task.orocos_task.use_sim_time
            end

            it 'sets use_sim_time to true if Conf.gazebo.use_sim_time is true' do
                Conf.gazebo.use_sim_time = true
                task = syskit_stub_deploy_and_configure(ImuTask)
                assert task.orocos_task.use_sim_time
            end
        end

        describe UnderwaterTask do
            it 'sets use_sim_time to false if Conf.gazebo.use_sim_time is false' do
                Conf.gazebo.use_sim_time = false
                task = syskit_stub_deploy_and_configure(UnderwaterTask)
                refute task.orocos_task.use_sim_time
            end

            it 'sets use_sim_time to true if Conf.gazebo.use_sim_time is true' do
                Conf.gazebo.use_sim_time = true
                task = syskit_stub_deploy_and_configure(UnderwaterTask)
                assert task.orocos_task.use_sim_time
            end
        end

        describe CameraTask do
            it 'sets use_sim_time to false if Conf.gazebo.use_sim_time is false' do
                Conf.gazebo.use_sim_time = false
                task = syskit_stub_deploy_and_configure(CameraTask)
                refute task.orocos_task.use_sim_time
            end

            it 'sets use_sim_time to true if Conf.gazebo.use_sim_time is true' do
                Conf.gazebo.use_sim_time = true
                task = syskit_stub_deploy_and_configure(CameraTask)
                assert task.orocos_task.use_sim_time
            end
        end

        describe GPSTask do
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

            it 'sets use_sim_time to false if Conf.gazebo.use_sim_time is false' do
                Conf.gazebo.use_sim_time = false
                task = syskit_stub_deploy_and_configure(GPSTask)
                refute task.orocos_task.use_sim_time
            end

            it 'sets use_sim_time to true if Conf.gazebo.use_sim_time is true' do
                Conf.gazebo.use_sim_time = true
                task = syskit_stub_deploy_and_configure(GPSTask)
                assert task.orocos_task.use_sim_time
            end

            it 'sets up the GPSTask latitude_origin and longitude_origin from '\
               'the spherical coordinates info in the SDF' do
                task = syskit_stub_deploy_and_configure GPSTask
                assert_in_delta 48.8580 * Math::PI / 180,
                                task.orocos_task.latitude_origin.rad, 1e-6
                assert_in_delta 2.2946 * Math::PI / 180,
                                task.orocos_task.longitude_origin.rad, 1e-6
            end

            it 'sets up the GPSTask origin property using the SDF global_origin' do
                task = syskit_stub_deploy_and_configure GPSTask
                assert((Eigen::Vector3.new(5_411_910.38, 1_000_000 - 448_258.92, 42) -
                       task.orocos_task.nwu_origin).norm < 1,
                       'invalid nwu_origin set on task: '\
                       "#{task.orocos_task.nwu_origin.to_a}")
            end

            it 'sets up the GPSTask UTM properties using the SDF UTM coordinates' do
                task = syskit_stub_deploy_and_configure GPSTask
                assert_equal 31, task.orocos_task.utm_zone
                assert_equal true, task.orocos_task.utm_north
            end
        end
    end
end
