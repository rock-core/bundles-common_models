require 'common_models/models/compositions/control_loop'

module CommonModels
    module Compositions
        describe ControlLoop do
            after do
                clear_newly_defined_models
            end

            describe "open loop" do
                attr_reader :command_type, :controller_srv, :controlled_system_srv, :model
                before do
                    @command_type = stub_type '/Command'
                    Services::ControlLoop.declare_open_loop 'Test', command_type
                    @controlled_system_srv = Services::TestOpenLoopControlledSystem.new_submodel
                    @controller_srv = Services::TestOpenLoopController.new_submodel

                    ControlLoop.declare_open_loop 'Test'
                end

                describe "the cascading specialization" do
                    before do
                        controller = Syskit::Component.create_proxy_task_model([controlled_system_srv,Services::Controller])
                        @model = ControlLoop.use(
                            'controller' => controller).narrow_model
                    end

                    it "provides the controlled system service" do
                        assert model.provides?(Services::TestOpenLoopControlledSystem)
                    end
                    it "exports the command in port" do
                        assert model.has_port?(:command_in)
                        assert_same command_type, model.command_in_port.type
                    end
                end
                describe "the forwarding specialization" do
                    before do
                        @model = ControlLoop.use(
                            'controller' => controller_srv,
                            'controlled_system' => controlled_system_srv).narrow_model
                    end

                    it "connects the command ports" do
                        assert(model.controller_child.command_out_port.connected_to?(
                            model.controlled_system_child.command_in_port))
                    end
                end
            end
            describe "closed loop" do
                attr_reader :command_type, :feedback_type, :controller_srv, :controlled_system_srv, :model
                before do
                    @command_type = stub_type '/Command'
                    @feedback_type = stub_type '/Feedback'
                    Services::ControlLoop.declare 'Test', command_type, feedback_type
                    @controlled_system_srv = Services::TestControlledSystem.new_submodel
                    @controller_srv = Services::TestController.new_submodel

                    ControlLoop.declare 'Test'
                end

                describe "the cascading specialization" do
                    before do
                        controller = Syskit::Component.create_proxy_task_model([controlled_system_srv,Services::Controller])
                        @model = ControlLoop.use(
                            'controller' => controller).narrow_model
                    end

                    it "provides the controlled system service" do
                        assert model.provides?(Services::TestControlledSystem)
                    end
                    it "exports the status_out port" do
                        assert model.has_port?(:status_out)
                        assert_same feedback_type, model.status_out_port.type
                    end
                    it "exports the command in port" do
                        assert model.has_port?(:command_in)
                        assert_same command_type, model.command_in_port.type
                    end
                end
                describe "the forwarding specialization" do
                    before do
                        @model = ControlLoop.use(
                            'controller' => controller_srv,
                            'controlled_system' => controlled_system_srv).narrow_model
                    end

                    it "connects the status ports" do
                        assert(model.controlled_system_child.status_out_port.connected_to?(
                            model.controller_child.status_in_port))
                    end
                    it "connects the command ports" do
                        assert(model.controller_child.command_out_port.connected_to?(
                            model.controlled_system_child.command_in_port))
                    end
                end
            end
            
        end
    end
end
