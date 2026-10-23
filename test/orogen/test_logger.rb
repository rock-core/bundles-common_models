# frozen_string_literal: true

using_task_library "logger"

module OroGen
    # NOTE: RockLogger is set to the logger model in orogen/logger.rb as OroGen.logger
    # is taken (can't access through OroGen.logger.LoggerTask)
    describe Syskit::RockLogger do
        def deploy_subject_syskit_model
            use_deployment("rock_logger").first
        end

        before do
            Syskit::RockLogger.reset_log_indexes
        end

        it { is_configurable }

        describe "handling of file on default loggers" do
            before do
                @deployment_m = Syskit::Deployment.new_submodel(name: "deployment") do
                    task "deployment_Logger", Syskit::RockLogger
                end
            end

            it "initializes the file property, following the default logger pattern" do
                deployment = syskit_stub_deployment("deployment", @deployment_m)
                logger = deployment.task "deployment_Logger"
                logger.default_logger = true
                syskit_configure_and_start(logger)
                assert_equal "deployment.0.log", logger.properties.file
            end

            it "increments the file index each time the same logger gets started" do
                deployment = syskit_stub_deployment("deployment", @deployment_m)
                logger = deployment.task "deployment_Logger"
                logger.default_logger = true
                syskit_configure_and_start(logger)
                assert_equal "deployment.0.log", logger.properties.file

                expect_execution { logger.stop! }.to { emit logger.stop_event }

                logger = deployment.task "deployment_Logger"
                logger.default_logger = true
                syskit_configure_and_start(logger)
                assert_equal "deployment.1.log", logger.properties.file
            end

            it "increments index in log file name when rotating the log" do
                deployment = syskit_stub_deployment("deployment", @deployment_m)
                logger = deployment.task "deployment_Logger"
                logger.default_logger = true
                syskit_configure_and_start(logger)

                assert_equal "deployment.0.log", logger.properties.file
                assert_equal ["deployment.0.log"], logger.rotate_log
                assert_equal "deployment.1.log", logger.properties.file
            end

            it "increments sequentially across rotations and restarts" do
                deployment = syskit_stub_deployment("deployment", @deployment_m)
                logger = deployment.task "deployment_Logger"
                logger.default_logger = true
                syskit_configure_and_start(logger)
                logger.rotate_log
                expect_execution { logger.stop! }.to { emit logger.stop_event }

                logger = deployment.task "deployment_Logger"
                logger.default_logger = true
                syskit_configure_and_start(logger)
                assert_equal "deployment.2.log", logger.properties.file
            end
        end

        it "does not rotate loggers that are not a deployment's default logger, " \
           "neither have a file_basename defined" do
            logger = syskit_stub_deploy_configure_and_start(Syskit::RockLogger)
            logger.properties.file = "test.log"
            assert_equal [], logger.rotate_log
            assert_equal "test.log", logger.properties.file
        end

        describe "handling of file_basename" do
            after do
                Syskit::RockLogger.reset_log_indexes
            end

            it "initializes the file property, following the default logger pattern" do
                logger = syskit_stub_deploy_configure_and_start(
                    Syskit::RockLogger.with_arguments(file_basename: "test")
                )
                assert_equal "test.0.log", logger.properties.file
            end

            it "increments the file index each time the same logger gets started" do
                @deployment_m = Syskit::Deployment.new_submodel(name: "deployment") do
                    task "logger", "logger::Logger"
                end
                deployment = syskit_stub_deployment("deployment", @deployment_m)
                logger = deployment.task "logger"
                logger.file_basename = "test"
                syskit_configure_and_start(logger)
                assert_equal "test.0.log", logger.properties.file

                expect_execution { logger.stop! }.to { emit logger.stop_event }

                logger = deployment.task "logger"
                logger.file_basename = "test"
                syskit_configure_and_start(logger)
                assert_equal "test.1.log", logger.properties.file
            end

            it "increments index in log file name when rotating the log" do
                logger = syskit_stub_deploy_configure_and_start(
                    Syskit::RockLogger.with_arguments(file_basename: "test")
                )

                assert_equal "test.0.log", logger.properties.file
                assert_equal ["test.0.log"], logger.rotate_log
                assert_equal "test.1.log", logger.properties.file
            end

            it "increments sequentially across rotations and restarts" do
                @deployment_m = Syskit::Deployment.new_submodel(name: "deployment") do
                    task "logger", "logger::Logger"
                end
                deployment = syskit_stub_deployment("deployment", @deployment_m)
                logger = deployment.task "logger"
                logger.file_basename = "test"
                syskit_configure_and_start(logger)
                assert_equal "test.0.log", logger.properties.file
                assert_equal ["test.0.log"], logger.rotate_log

                expect_execution { logger.stop! }.to { emit logger.stop_event }

                logger = deployment.task "logger"
                logger.file_basename = "test"
                syskit_configure_and_start(logger)
                assert_equal "test.2.log", logger.properties.file
            end
        end

        describe "log index management" do
            before do
                skip unless Roby.app.respond_to?(:syskit_register_new_log)

                @deployment_m = Syskit::Deployment.new_submodel(name: "deployment") do
                    task "deployment_Logger", Syskit::RockLogger
                end

                deployment = syskit_stub_deployment("deployment", @deployment_m)
                @logger = deployment.task "deployment_Logger"
                @logger.default_logger = true

                @log_index = Roby.app.syskit_create_log_index

                base_port = Syskit::NetworkGeneration::LoggerConfigurationSupport
                            .logger_dynamic_port_of(Syskit::RockLogger)
                @logger.instanciate_dynamic_input_port(
                    "some.stream", "/uint32_t", base_port
                )
            end

            after do
                if @log_index
                    @log_index.dispose
                    FileUtils.rm_f Roby.app.syskit_log_index_path
                end
            end

            it "registers the file on start" do
                Timecop.freeze(t0 = Time.now.floor(5)) do
                    syskit_configure_and_start(@logger)
                end
                @log_index.write_log_rotation(Time.now)

                expected = [
                    { id: 1, basename: "deployment", sequence: 0,
                      log_rotation_id: 1, start_time: t0, end_time: nil,
                      archive_name: nil }
                ]
                assert_equal expected, @log_index.db[:log_files].select.to_a
            end

            it "registers the file's end on stop" do
                Timecop.freeze(t0 = Time.now.floor(5)) do
                    syskit_configure_and_start(@logger)
                end
                Timecop.freeze(t1 = Time.now.floor(5)) do
                    expect_execution { @logger.stop! }.to_emit(@logger.stop_event)
                end
                @log_index.write_log_rotation(Time.now)

                expected = [
                    { id: 1, basename: "deployment", sequence: 0,
                      log_rotation_id: 1, start_time: t0, end_time: t1,
                      archive_name: nil }
                ]
                assert_equal expected, @log_index.db[:log_files].select.to_a
            end

            it "registers a file's rotation in rotate_log" do
                Timecop.freeze(t0 = Time.now.floor(5)) do
                    syskit_configure_and_start(@logger)
                end
                @log_index.write_log_rotation(Time.now)

                Timecop.freeze(t1 = Time.now.floor(5)) do
                    @logger.rotate_log
                end
                @log_index.write_log_rotation(Time.now)

                expected = [
                    { id: 1, basename: "deployment", sequence: 0,
                      log_rotation_id: 1, start_time: t0, end_time: t1,
                      archive_name: nil },
                    { id: 2, basename: "deployment", sequence: 1,
                      log_rotation_id: 2, start_time: t1, end_time: nil,
                      archive_name: nil }
                ]
                assert_equal expected, @log_index.db[:log_files].select.to_a
            end
        end
    end
end
