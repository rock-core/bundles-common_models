require 'common_models/models/services/control_loop'

module CommonModels
    module Services
        describe ControlLoop do
            after do
                clear_newly_defined_models
            end

            it 'raises if the services are already declared' do
                type = stub_type '/Mock'
                ControlLoop.declare_open_loop 'Test', type
                assert_raises(ControlLoop::AlreadyDeclared) do
                    ControlLoop.declare_open_loop 'Test', type
                end
            end

            describe 'open-loop control' do
                attr_reader :command_type
                before do
                    @command_type = stub_type '/Command'
                    ControlLoop.declare_open_loop 'Test', command_type
                end

                it 'properly sets up the relationship between the open loop models and the root models' do
                    assert TestOpenLoopController.provides?(Controller)
                    assert TestOpenLoopControlledSystem.provides?(ControlledSystem)
                end
                it 'creates ports that allow for an open-loop connection' do
                    assert_equal command_type, TestOpenLoopController.command_out_port.type
                    assert_equal command_type, TestOpenLoopControlledSystem.command_in_port.type
                    TestOpenLoopController.command_out_port.can_connect_to?(TestOpenLoopControlledSystem.command_in_port)
                end
            end

            describe 'closed-loop control' do
                attr_reader :command_type, :status_type
                before do
                    @command_type = stub_type '/Command'
                    @status_type = stub_type '/Status'
                    ControlLoop.declare 'Test', command_type, status_type
                end

                it 'sets up the relationship between the closed loop models and the root models' do
                    assert TestController.provides?(Controller)
                    assert TestControlledSystem.provides?(ControlledSystem)
                end
                it 'sets up the relationship between the open and closed loop models' do
                    assert TestController.provides?(TestOpenLoopController)
                    assert TestControlledSystem.provides?(TestOpenLoopControlledSystem)
                end
                it 'leaves the open-loop models untouched' do
                    assert !TestOpenLoopController.has_port?(:status_in)
                    assert !TestOpenLoopControlledSystem.has_port?(:status_out)
                end
                it 'creates ports that allow for a feedback' do
                    assert_equal status_type, TestController.status_in_port.type
                    assert_equal status_type, TestControlledSystem.status_out_port.type
                    TestControlledSystem.status_out_port.can_connect_to?(TestController.status_in_port)
                end

                describe 'controller_for' do
                    it 'returns the generated controller model' do
                        assert_same TestControlledSystem,
                            ControlLoop.controlled_system_for('Test')
                    end
                end
                describe 'controlled_system_for' do
                    it 'returns the generated controlled system model' do
                        assert_same TestController,
                            ControlLoop.controller_for('Test')
                    end
                end
            end
            describe 'verify the namespace specification option' do
                before do
                    @n = Module.new
                    @command_type = stub_type '/Command'
                    @status_type = stub_type '/Status'
                    ControlLoop.declare 'Test', @command_type, @status_type, namespace: @n
                end
                it 'sets up the relationship between the closed loop models and the root models' do                    # puts n::TestController.provides?(Controller)
                    assert @n::TestController.provides?(Controller)
                    assert @n::TestControlledSystem.provides?(ControlledSystem)
                end
                it 'sets up the relationship between the open and closed loop models' do
                    assert @n::TestController.provides?(@n::TestOpenLoopController)
                    assert @n::TestControlledSystem.provides?(@n::TestOpenLoopControlledSystem)
                end
            end
        end
    end
end
