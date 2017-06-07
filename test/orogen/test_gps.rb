using_task_library 'gps'

module OroGen::Gps
    describe BaseTask do
    end

    describe GPSDTask do
        it { is_configurable }

        it "should set the UTM local origin on the task if it is set on Conf" do
            origin = Conf.utm_local_origin = Eigen::Vector3.new(1, 2, 3)
            device = syskit_stub_device(CommonModels::Devices::GPS::Generic, using: GPSDTask, as: 'dev')
            task = syskit_stub_deploy_and_configure(device)
            assert_equal origin, task.orocos_task.origin
        end
    end

    describe MB500Task do
        it { is_configurable }

        it "should set the UTM local origin on the task if it is set on Conf" do
            origin = Conf.utm_local_origin = Eigen::Vector3.new(1, 2, 3)
            device = syskit_stub_device(CommonModels::Devices::GPS::MB500, using: MB500Task, as: 'dev')
            task = syskit_stub_deploy_and_configure(device)
            assert_equal origin, task.orocos_task.origin
        end
    end
end
