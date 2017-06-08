import_types_from 'base'

module CommonModels
    module Services
        # A single beam in a sonar system
        data_service_type 'SonarBeam' do
            output_port 'samples', '/base/samples/SonarBeam'
        end
    end
end
