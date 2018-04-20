module CommonModels
    module Devices
        module Gazebo
            device_type 'Entity' do
                extend_device_configuration do
                    # This entity's SDF representation
                    dsl_attribute :sdf

                    # For consistency with Profile
                    def sdf_model
                        sdf
                    end
                end
            end
        end
    end
end
