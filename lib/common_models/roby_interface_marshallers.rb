# frozen_string_literal: true

require "eigen"
require "roby/interface/v2/protocol"

module CommonModels # :nodoc:
    # Custom marshallers for the v2 Roby interface protocol
    module RobyInterfaceMarshallers
        def self.register_marshallers(registry)
            registry.allow_classes(
                Eigen::Vector3,
                Eigen::Quaternion
            )
        end

        def self.install
            register_marshallers(Roby::Interface::V2::Protocol)
        end

        install
    end
end
