# frozen_string_literal: true

using_task_library "logger"

module OroGen
    # NOTE: RockLogger is set to the logger model in orogen/logger.rb as OroGen.logger
    # is taken (can't access through OroGen.logger.LoggerTask)
    describe Syskit::RockLogger do
        def deploy_subject_syskit_model
            use_deployment("rock_logger").first
        end

        it { is_configurable }

        describe "handling of file on default loggers" do
            before do
                @deployment_m = Syskit::Deployment.new_submodel(name: "deployment") do
                    add_default_logger
                end
            end

            after do
                Syskit::RockLogger.reset_log_indexes
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

            it "does not rotate for loggers that are not a deployment's default logger" do
                deployment = syskit_stub_deployment("deployment", @deployment_m)
                logger = deployment.task "deployment_Logger"
                logger.properties.file = "test.log"
                syskit_configure_and_start(logger)

                assert_equal "test.log", logger.properties.file
                assert_equal [], logger.rotate_log
                assert_equal "test.log", logger.properties.file
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
    end
end
