import_types_from 'base'

module CommonModels
    module Services
        data_service_type 'Wrench' do
            input_port 'wrench_samples', '/base/samples/Wrench'
        end
    end
end
