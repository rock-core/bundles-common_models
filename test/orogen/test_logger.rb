# frozen_string_literal: true
using_task_library 'logger'

module OroGen
    # OroGen.logger already exists, we can't access the model for logger::Logger
    # using the method syntax
    logger_m = OroGen.syskit_model_by_orogen_name("logger::Logger")

    describe logger_m do
        def deploy_subject_syskit_model
            use_deployment("rock_logger").first
        end

        it { is_configurable }
    end
end
