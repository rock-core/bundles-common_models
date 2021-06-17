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
                task = syskit_stub_deploy_and_configure(logger_m)
                task.orocos_task.property("overwrite_existing_files").write(false)
                task.orocos_task.property("auto_timestamp_files").write(false)

                assert_empty(task.orocos_task.property("file").read)

                task.rotate_log

                assert_equal(
                    "#{task.orocos_task.basename}.0.log",
                    task.orocos_task.property("file").read
                )

                task.rotate_log

                assert_equal(
                    "#{task.orocos_task.basename}.1.log",
                    task.orocos_task.property("file").read
                )
            end

            it "returns previous file after rotation" do
                task = syskit_stub_deploy_and_configure(logger_m)
                task.orocos_task.property("overwrite_existing_files").write(false)
                task.orocos_task.property("auto_timestamp_files").write(false)

                assert_equal [""], task.rotate_log

                assert_equal(
                    ["#{task.orocos_task.basename}.0.log"],
                    task.rotate_log
                )

                assert_equal(
                    ["#{task.orocos_task.basename}.1.log"],
                    task.rotate_log
                )
            end
        end
    end
end
