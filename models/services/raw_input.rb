# frozen_string_literal: true

import_types_from "iodrivers_base"

module CommonModels
    module Services
        # Representation of a raw input stream
        data_service_type "RawInput" do
            input_port "raw_in", "/iodrivers_base/RawPacket"
        end
    end
end
