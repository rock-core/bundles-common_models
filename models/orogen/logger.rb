# frozen_string_literal: true

module Syskit
    # Provide an alias for the RockLogger is set to the logger model in orogen/logger.rb
    # as OroGen.logger is taken (can't access through OroGen.logger.LoggerTask)
    RockLogger = OroGen.syskit_model_by_orogen_name("logger::Logger")
end

Syskit.extend_model Syskit::RockLogger do
    class << self
        attr_reader :logfile_indexes

        def reset_log_indexes
            @logfile_indexes = {}
        end
    end
    @logfile_indexes = {}

    provides Syskit::LoggerService
    include Syskit::NetworkGeneration::LoggerConfigurationSupport

    stub do
        def createLoggingPort(port_name, port_type, _metadata) # rubocop:disable Naming/MethodName
            create_input_port(port_name, port_type)
            true
        end
    end

    # A file basename to be used for auto-rotation of logs
    #
    # If nil, logs won't be rotated or indexed. Default loggers are managed
    # automatically regardless of this argument's value
    argument :file_basename, default: nil

    # True if this logger is its deployment's default logger
    #
    # In this case, it will set itself up using the deployment's logging
    # configuration
    attr_predicate :default_logger?, true

    def update_properties
        super

        properties.overwrite_existing_files = false
        properties.auto_timestamp_files = false
    end

    event :start do |context|
        if (path = resolve_next_file_path)
            properties.file = path
        end

        super(context)
    end

    # Enumerate the streams that are currently being logged by this logger
    def each_stream
        return enum_for(:each_stream) unless block_given?

        each_input_port do |port|
            yield(port.name, port.type) if port.dynamic?
        end
    end

    # @api private
    #
    # Return a description of the logged streams that is compatible with
    #  {Syskit::RobyApp::LogIndex}'s API
    #
    # @return [Array<(String,String)>]
    def log_index_stream_description
        each_stream.map { |name, type| [name, type.name] }
    end

    on :start do |event|
        if log_index?
            Roby.app.syskit_register_new_log(
                event.time, properties.file, log_index_stream_description
            )
        end
    end

    on :stop do |event|
        Roby.app.syskit_register_finished_log(event.time, properties.file) if log_index?
    end

    def resolve_next_file_path
        basename =
            if default_logger?
                default_logger_file_name
            else
                file_basename
            end

        next_file_path(basename) if basename
    end

    def default_logger_file_name
        orocos_name.sub(/_[L|l]ogger/, "")
    end

    def path_next_index(log_file_name)
        Syskit::RockLogger.logfile_indexes[log_file_name] =
            Syskit::RockLogger.logfile_indexes.fetch(log_file_name, -1) + 1
    end

    def default_logger_log_dir
        Syskit.conf.process_server_config_for(log_server_name).log_dir
    end

    # Sets up the default logger of this process
    def next_file_path(log_file_name)
        index = path_next_index(log_file_name)

        log_file_path = "#{log_file_name}.#{index}.log"

        log_dir = default_logger_log_dir
        # NOTE: log_dir should be nil to mean "no log dir", not empty.
        # This is a workaround to help migrating from Syskit code that sets it to empty
        log_file_path = File.join(log_dir, log_file_path) if log_dir && !log_dir.empty?
        log_file_path
    end

    def log_server_name
        execution_agent.arguments[:on]
    end

    def log_index?
        return @log_index unless @log_index.nil?

        @log_index = Roby.app.respond_to?(:syskit_register_new_log)
    end

    def rotate_log
        return [] unless (path = resolve_next_file_path)

        previous_file = properties.file
        properties.file = path

        if log_index?
            time = Time.now
            Roby.app.syskit_register_finished_log(time, previous_file)
            Roby.app.syskit_register_new_log(time, path, log_index_stream_description)
        end

        [previous_file]
    end

    def current_files
        [properties.file]
    end
end
