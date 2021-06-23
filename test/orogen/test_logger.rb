# frozen_string_literal: true

using_task_library "logger"

module OroGen
    # OroGen.logger already exists, we can't access the model for logger::Logger
    # using the method syntax
    logger_m = OroGen.syskit_model_by_orogen_name("logger::Logger")

    describe logger_m do
        def deploy_subject_syskit_model
            use_deployment("rock_logger").first
        end

        it { is_configurable }

        describe "log rotation" do
            it "increments index in log file name after rotation" do
                task = syskit_stub_deploy_configure_and_start

                assert_empty task.properties.file

                task.rotate_log

                assert_equal(
                    "#{task.orocos_name}.0.log",
                    task.properties.file
                )

                task.rotate_log

                assert_equal(
                    "#{task.orocos_name}.1.log",
                    task.properties.file
                )
            end

            it "returns previous file after rotation" do
                task = syskit_stub_deploy_configure_and_start

                assert_empty task.rotate_log

                assert_equal(
                    ["#{task.orocos_name}.0.log"],
                    task.rotate_log
                )

                assert_equal(
                    ["#{task.orocos_name}.1.log"],
                    task.rotate_log
                )
            end
        end
    end
end
