require 'models/compositions/constant_generator'
module Rock
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
                    sample = assert_has_one_new_sample(generator.out_port)
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
                sample = assert_has_one_new_sample(task.out_port)
                assert_in_delta sample, 20, 0.01
            end

            describe "the task termination" do
                attr_reader :task
                before do
                    @task = syskit_stub_deploy_configure_and_start(generator_m.with_arguments(values: Hash['out' => 10]))
                end

                it "kills the write thread on exit" do
                    plan.unmark_mission_task(@task)
                    reader = task.orocos_task.out.reader
                    task.stop!
                    task.stop_event.on { |_| reader.clear }
                    assert_event_emission task.interrupt_event
                    refute task.aborted_event.emitted?
                    refute reader.read_new
                end

                it "aborts if the write thread raises an exception" do
                    plan.add_mission_task(task.execution_agent)
                    assert_fatal_exception(Roby::MissionFailedError, failure_point: task.aborted_event, tasks: [task]) do
                        task.write_thread.raise Interrupt
                        assert_event_emission task.aborted_event
                    end
                    assert task.aborted_event.emitted?
                    # Verify that the task got stopped properly regardless of
                    # the abort
                    assert_equal :STOPPED, task.orocos_task.rtt_state
                end
            end
        end
    end
end

