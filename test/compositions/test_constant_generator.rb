require 'models/compositions/constant_generator'
module CommonModels
    module Compositions
        describe ConstantGenerator do
            attr_reader :srv_m, :generator_m

            before do
                @srv_m = Syskit::DataService.new_submodel do
                    output_port 'out', 'double'
                end
                @generator_m = ConstantGenerator.for(srv_m)
            end

            describe "defined from a data service" do
                it "constantly writes data to its output port" do
                    generator = syskit_stub_deploy_configure_and_start(generator_m.with_arguments(values: Hash['out' => 10]))
                    sample = expect_execution.to { have_one_new_sample generator.out_port }
                    assert_in_delta sample, 10, 0.01
                end
                it "returns the same component over and over again" do
                    assert_same generator_m, ConstantGenerator.for(srv_m)
                end
            end

            it "validates that the keys in 'values' are actual port names" do
                assert_raises(ArgumentError) do
                    generator_m.with_arguments(values: Hash['bla' => 10]).
                        instanciate(plan)
                end
            end

            it "allows to tune the values by overriding #values" do
                overload_m = generator_m.new_submodel
                overload_m.class_eval do
                    def values
                        Hash['out' => super['out'] * 2]
                    end
                end
                task = syskit_stub_deploy_configure_and_start(overload_m.with_arguments(values: Hash['out' => 10]))
                sample = expect_execution.to { have_one_new_sample task.out_port }
                assert_in_delta sample, 20, 0.01
            end

            describe "the task termination" do
                attr_reader :task
                before do
                    @task = syskit_stub_deploy_configure_and_start(generator_m.with_arguments(values: Hash['out' => 10]))
                end

                it "kills the write thread on exit" do
                    reader = task.orocos_task.out.reader
                    expect_execution do
                        task.stop!
                        task.stop_event.on { |_| reader.clear }
                    end.to do
                        emit task.interrupt_event
                        not_emit task.aborted_event
                    end
                    refute reader.read_new
                end

                it "interrupts the task if the write thread raises an exception" do
                    plan.add_mission_task(task.execution_agent)
                    expect_execution { task.write_thread.raise Interrupt }.
                        to do
                            emit task.write_thread_error_event
                            emit task.stop_event
                        end
                    # Verify that the task got stopped properly regardless of
                    # the abort
                    assert_equal :STOPPED, task.orocos_task.rtt_state
                end

                it "reports the termination cause in the event" do
                    plan.add_mission_task(task.execution_agent)
                    e = RuntimeError.exception "test"
                    finished = expect_execution { task.write_thread.raise e }.
                        to { emit task.write_thread_error_event }
                    assert_equal e, finished.context.first
                end
            end
        end
    end
end

