# frozen_string_literal: true

Syskit.extend_model OroGen.logger.Logger do # rubocop:disable Metrics/BlockLength
    provides Syskit::LoggerService, as: "logger_service"

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
        new_file = orocos_task.file
        unless orocos_task.auto_timestamp_files
            previous_file, new_file = get_file_with_incremented_number(
                previous_file, new_file
            )
        end
        orocos_task.file = new_file
        previous_file
    end

    def get_file_with_incremented_number(previous_file, new_file)
        new_file, log_number = separate_name_and_number(new_file)
        if log_number.empty?
            log_number = "_1"
            previous_file = add_number_suffix(previous_file, log_number)
        end
        new_file << increment_number(log_number)
        new_file << ".log" if previous_file.match?(/.log$/)
        [previous_file, new_file]
    end

    def separate_name_and_number(file_name)
        file_name = file_name.partition(/.log$/).first
        file_name.partition(/_\d+$/)
    end

    def add_number_suffix(file_name, number)
        if file_name.match?(/.log$/)
            file_name.partition(/.log$/).first + number + ".log"
        else
            file_name + number
        end
    end

    def increment_number(number)
        number = number[1, number.length].to_i + 1
        "_" + number.to_s
    end
end
