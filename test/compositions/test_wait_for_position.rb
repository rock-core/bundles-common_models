require 'common_models/models/compositions/wait_for_position'

module CommonModels
    module Compositions
        describe WaitForPosition do
            describe "#acceptable?" do
                attr_reader :cov_position
                before do
                    @cov_position = Array.new(9, Base.unknown)
                end

                it "returns true if there is a tolerance in x and the variance matches" do
                    task = WaitForPosition.new(tolerance: Hash[x: 2])
                    cov_position[0] = 3
                    assert task.acceptable?(cov_position)
                end
                it "returns false if there is a tolerance in x and the variance is NaN" do
                    task = WaitForPosition.new(tolerance: Hash[x: 2])
                    refute task.acceptable?(cov_position)
                end
                it "returns false if the tolerance in x is lower than the variance" do
                    task = WaitForPosition.new(tolerance: Hash[x: 2])
                    cov_position[0] = 5
                    refute task.acceptable?(cov_position)
                end

                it "returns true if there is a tolerance in x and the variance matches" do
                    task = WaitForPosition.new(tolerance: Hash[y: 2])
                    cov_position[4] = 3
                    assert task.acceptable?(cov_position)
                end
                it "returns false if there is a tolerance in y and the variance is NaN" do
                    task = WaitForPosition.new(tolerance: Hash[y: 2])
                    refute task.acceptable?(cov_position)
                end
                it "returns false if the tolerance in y is lower than the variance" do
                    task = WaitForPosition.new(tolerance: Hash[y: 2])
                    cov_position[4] = 5
                    refute task.acceptable?(cov_position)
                end

                it "returns true if there is a tolerance in x and the variance matches" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2])
                    cov_position[8] = 3
                    assert task.acceptable?(cov_position)
                end
                it "returns false if there is a tolerance in z and the variance is NaN" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2])
                    refute task.acceptable?(cov_position)
                end
                it "returns false if the tolerance in z is lower than the variance" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2])
                    cov_position[8] = 5
                    refute task.acceptable?(cov_position)
                end

                it "returns true if there are tolerances in x and y and the variance matches" do
                    task = WaitForPosition.new(tolerance: Hash[x: 2, y: 3])
                    cov_position[0] = 3
                    cov_position[4] = 5
                    assert task.acceptable?(cov_position)
                end
                it "returns false if there are tolerances in x and y but only x matches" do
                    task = WaitForPosition.new(tolerance: Hash[x: 2, y: 3])
                    cov_position[0] = 3
                    cov_position[4] = 10
                    refute task.acceptable?(cov_position)
                end
                it "returns false if there are tolerances in x and y but only y matches" do
                    task = WaitForPosition.new(tolerance: Hash[x: 2, y: 3])
                    cov_position[0] = 5
                    cov_position[4] = 3
                    refute task.acceptable?(cov_position)
                end
                it "returns false if there are tolerances in x and y and none matches" do
                    task = WaitForPosition.new(tolerance: Hash[x: 2, y: 3])
                    cov_position[0] = 5
                    cov_position[4] = 10
                    refute task.acceptable?(cov_position)
                end

                it "returns true if there are tolerances in y and z and the variance matches" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2, y: 3])
                    cov_position[8] = 3
                    cov_position[4] = 5
                    assert task.acceptable?(cov_position)
                end
                it "returns false if there are tolerances in z and y but only z matches" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2, y: 3])
                    cov_position[8] = 3
                    cov_position[4] = 10
                    refute task.acceptable?(cov_position)
                end
                it "returns false if there are tolerances in z and y but only y matches" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2, y: 3])
                    cov_position[8] = 5
                    cov_position[4] = 3
                    refute task.acceptable?(cov_position)
                end
                it "returns false if there are tolerances in z and y and none matches" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2, y: 3])
                    cov_position[8] = 5
                    cov_position[4] = 10
                    refute task.acceptable?(cov_position)
                end

                it "returns true if there are tolerances in x and z and the variance matches" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2, x: 3])
                    cov_position[8] = 3
                    cov_position[0] = 5
                    assert task.acceptable?(cov_position)
                end
                it "returns false if there are tolerances in z and x but only z matches" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2, x: 3])
                    cov_position[8] = 3
                    cov_position[0] = 10
                    refute task.acceptable?(cov_position)
                end
                it "returns false if there are tolerances in z and x but only x matches" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2, x: 3])
                    cov_position[8] = 5
                    cov_position[0] = 3
                    refute task.acceptable?(cov_position)
                end
                it "returns false if there are tolerances in z and x and none matches" do
                    task = WaitForPosition.new(tolerance: Hash[z: 2, x: 3])
                    cov_position[8] = 5
                    cov_position[0] = 10
                    refute task.acceptable?(cov_position)
                end
            end

            it "boes not emit success if acceptable? returns false" do
                task = syskit_stub_deploy_configure_and_start(WaitForPosition.with_arguments(tolerance: Hash[x: 0.9, y: 2.1, z: 3.1]))
                rbs = Types.base.samples.RigidBodyState.Invalid
                rbs.cov_position.data = [1, 0, 0, 0, 4, 0, 0, 0, 9]
                task.position_child.orocos_task.position_samples.write(rbs)
                flexmock(task).should_receive(:acceptable?).once.with(rbs.cov_position.data).pass_thru
                expect_execution.to { have_running task }
            end

            it "emits success if acceptable? returns true" do
                task = syskit_stub_deploy_configure_and_start(WaitForPosition.with_arguments(tolerance: Hash[x: 1.1, y: 2.1, z: 3.1]))
                rbs = Types.base.samples.RigidBodyState.Invalid
                rbs.cov_position.data = [1, 0, 0, 0, 4, 0, 0, 0, 9]
                task.position_child.orocos_task.position_samples.write(rbs)
                flexmock(task).should_receive(:acceptable?).once.with(rbs.cov_position.data).pass_thru
                expect_execution.to { emit task.success_event }
            end
        end
    end
end
