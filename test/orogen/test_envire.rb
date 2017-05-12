using_task_library 'envire'
require 'fakefs/safe'

module Envire
    describe SynchronizationTransmitter do
        before do
            FakeFS.activate!
        end
        after do
            FakeFS.deactivate!
            FakeFS::FileSystem.clear
        end

        it "should fail to configure if the provided initial map does not exist" do
            envire = syskit_deploy(SynchronizationTransmitter.with_arguments(initial_map:'bogus_path'))
            assert_raises(ArgumentError) do
                syskit_configure(envire)
            end
        end

        it "should load the provided environment on the task" do
            FileUtils.mkdir_p "/environment"
            envire = syskit_deploy(SynchronizationTransmitter.with_arguments(initial_map: 'bogus_path'))
            flexmock(envire).should_receive_operation(:loadEnvironment).once.
                with('/environment')
            syskit_configure(envire)
        end
    end

    describe SynchronizationReceiver do
        it { is_configurable }
    end
end
