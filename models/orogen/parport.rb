require 'common_models/models/blueprints/sensors'

Parport.com_bus_type 'GPIOReader', :message_type => '/parport/StateChange', :override_policy => false
Dev::Bus.com_bus_type 'Parport' do
    provides Parport::GPIOReader

    extend_attached_device_configuration do
        dsl_attribute :parport_pin do |pin_id|
            Integer(pin_id)
        end
    end
end

class OroGen::Parport::Task
    driver_for Dev::Bus::Parport, :as => 'driver'

    def configure
        super
        bus_name = self.parport_name
        each_attached_device do |dev|
            pin = dev.parport_pin
            name = dev.name
            Robot.info "#{bus_name}: watching #{name} on #{pin}"
            orogen_task.watch_pin(name, pin)
        end
    end
end

