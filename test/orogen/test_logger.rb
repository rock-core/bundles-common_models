# frozen_string_literal: true
using_task_library 'logger'

module OroGen
    describe logger.Logger do
        it { is_configurable }
    end
end

module Syskit
    module RobyApp
        describe Plugin do
            before do
                # Turns Off auto-rotation in Plugin preparation method
                Syskit.conf.log_rotation_period = nil
                # Configurates Test Process Server and Log Transfer Server
                @server_threads = []
                @process_servers = []
                register_process_server("test_ps")
                app.log_transfer_ip = "127.0.0.1"
                app.setup_local_log_transfer_server
            end

            after do
                close_process_servers
                app.log_transfer_ip = nil
            end

            it "Verifies log rotation" do
                @ps_logfile = create_test_file(@ps_log_dir)
                path = File.join(app.log_dir, "logfile.log")
                refute File.exist?(path)

                app.rotate_logs
                
                assert_equal File.read(path), File.read(@ps_logfile)
            end

            def create_test_file(ps_log_dir)
                logfile = File.join(ps_log_dir, "logfile.log")
                File.open(logfile, "wb") do |f|
                    # create random 5 MB file
                    f.write(SecureRandom.random_bytes(547))
                end
                logfile
            end

            def register_process_server(name)
                server = RemoteProcesses::Server.new(app, port: 0)
                server.open

                thread = Thread.new { server.listen }
                @server_threads << thread

                client = Syskit.conf.connect_to_orocos_process_server(
                    name, "localhost",
                    port: server.port,
                    model_only_server: false
                )
                @process_servers << [name, client]

                config_log_dir(client)
            end

            def config_log_dir(client)
                @ps_log_dir = make_tmpdir
                client.create_log_dir(
                    @ps_log_dir, Roby.app.time_tag,
                    { "parent" => Roby.app.app_metadata }
                )
            end

            def close_process_servers
                @process_servers.each do |name, client|
                    client.close
                    Syskit.conf.remove_process_server(name)
                end
                @server_threads.each do |thread|
                    thread.raise Interrupt
                    thread.join
                end
            end

        end
    end
end
