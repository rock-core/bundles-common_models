# frozen_string_literal: true

require "common_models/models/compositions/pose_predicate"

module CommonModels
    module Compositions
        # Composition that verifies whether a certain pose is reached within a
        # given timeout
        class MaintainPose < PosePredicate
            argument :duration

            event :exceeds_tolerance
            forward exceeds_tolerance: :failed
            event :no_samples
            forward no_samples: :failed

            script do
                pose_r = pose_child.pose_samples_port.reader

                poll do
                    if duration && (lifetime > duration)
                        if last_pose
                            success_event.emit
                        else
                            no_samples_event.emit
                        end
                    end

                    if sample = pose_r.read_new
                        @last_pose = Types.base.Pose.new(
                            position: sample.position,
                            orientation: sample.orientation
                        )
                        unless within_tolerance?(sample)
                            exceeds_tolerance_event.emit(
                                { expected: rbs_to_hash(self.pose),
                                  actual: rbs_to_hash(@last_pose) }
                            )
                        end
                    end
                end
            end
        end
    end
end
