require 'models/devices/bus/raw_io'

module CommonModels
    module Devices
        module Bus
            describe RawIO do
                # What one usually wants to test for a Bus would be the
                # extensions module for attached devices ... Example:
                # it "allows to specify a device bus ID on the attached devices" do
                #     dev = syskit_stub_attached_device(RawIo)
                #     dev.bus_id(0x01, 0x11)
                #     assert_equal [0x01, 0x11], dev.bus_id
                # end

                # ... or the one for the device itself. Example:
                # it "allows to specify the bus baudrate" do
                #     dev = syskit_stub_device(RawIo)
                #     dev.baudrate(1_000_000) # 1Mbit
                #     assert_equal 1_000_000, dev.baudrate
                # end
            end
        end
    end
end
