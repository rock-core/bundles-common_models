# frozen_string_literal: true

require "common_models/models/services/raw_input"
require "common_models/models/services/raw_output"

module CommonModels
    module Services
        # Representation of a raw I/O stream
        data_service_type "RawIO" do
            provides RawInput
            provides RawOutput
        end
    end
end
