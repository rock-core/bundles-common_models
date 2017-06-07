import_types_from 'canbus'

module CommonModels
    module Devices
        module Bus
            com_bus_type 'CAN', message_type: '/canbus/Message' do
                worstcase_processing_time 0.2 
                extend_attached_device_configuration do
                    dsl_attribute :can_id do |id, mask|
                        mask ||= id
                        id   = Integer(id)
                        mask = Integer(mask)
                        if (id & mask) != id
                            raise ArgumentError, "wrong id/mask combination: some bits in the ID are not set in the mask, and therefore the filter will never match"
                        end
                        [id, mask]
                    end
                end
            end
        end
    end
end
