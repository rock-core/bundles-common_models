require 'common_models/models/services/position'

module CommonModels
    module Compositions
        # Composition that waits for a given position stream's precision to be
        # below a given tolerance
        #
        # It emits success when this happens
        class WaitForPosition < Syskit::Composition
            # The tolerance in the x, y and z variance
            #
            # If some tolerances are not given, these coordinates will be
            # ignored
            argument :tolerance

            # The position stream
            add CommonModels::Services::Position, as: 'position'

            # Tests whether the cov_position of a rbs is acceptable w.r.t. {#tolerance}
            #
            # @param [Array<Float>] cov_position the flattened 3x3 covariance matrix
            def acceptable?(cov_position)
                (!(x = tolerance[:x]) || cov_position[0] < x ** 2) &&
                    (!(y = tolerance[:y]) || cov_position[4] < y ** 2) &&
                    (!(z = tolerance[:z]) || cov_position[8] < z ** 2)
            end

            script do
                reader = position_child.position_samples_port.reader
                poll_until success_event do
                    if (p = reader.read_new) && acceptable?(p.cov_position.data)
                        success_event.emit p
                    end
                end
            end
        end
    end
end
