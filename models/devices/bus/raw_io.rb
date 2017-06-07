import_types_from 'iodrivers_base'

module CommonModels
    module Devices
        module Bus
            # Base model for busses that are using iodrivers_base RawPacket for
            # communication
            #
            # One would usually NOT directly define driver for this, but instead
            # make other com bus types provide it
            com_bus_type 'RawIO', message_type: '/iodrivers_base/RawPacket'
        end
    end
end
