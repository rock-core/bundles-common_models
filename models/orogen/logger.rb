# frozen_string_literal: true

require "syskit/network_generation/logger"

# OroGen.logger already exists, we can't access the model for logger::Logger
# using the method syntax
logger_m = OroGen.syskit_model_by_orogen_name("logger::Logger")

Syskit.extend_model logger_m do # rubocop:disable Metrics/BlockLength
    provides Syskit::LoggerService

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

    def rotate_log
        previous_file = orocos_task.current_file

        setup_default_logger(orocos_task)

        [previous_file]
    end
end
