require 'models/devices/gps/generic'

module CommonModels
    module Devices
        module GPS
            describe Generic do
                # # What one usually wants to test for a Device would be the
                # # extensions module.
                # it "allows to specify the baudrate" do
                #     dev = syskit_stub_device(Generic)
                #     dev.baudrate(1_000_000) # 1Mbit
                #     assert_equal 1_000_000, dev.baudrate
                # end
            end
        end
    end
end
