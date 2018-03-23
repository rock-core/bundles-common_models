require 'common_models/models/devices/bus/can'
using_task_library 'canbus'
module CommonModels
    module Devices
        module Bus
            describe CAN do
                it "allows to specify the can ID on the attached devices" do
                    dev = syskit_stub_attached_device(CAN)
                    dev.can_id(0x01, 0x11)
                    assert_equal [0x01, 0x11], dev.can_id
                end

                it "raises ArgumentError if the can ID and mask do not make sense" do
                    dev = syskit_stub_attached_device(CAN)
                    assert_raises(ArgumentError) do
                        dev.can_id(0x0f, 0x0e)
                    end
                end
            end
        end
    end
end

