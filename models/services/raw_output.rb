# frozen_string_literal: true

import_types_from "iodrivers_base"

module CommonModels
    module Services
        # Representation of a raw output stream
        data_service_type "RawOutput" do
            output_port "raw_out", "/iodrivers_base/RawPacket"
        end
    end
end
