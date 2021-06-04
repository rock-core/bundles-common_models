# frozen_string_literal: true
using_task_library 'logger'

# OroGen.logger already exists, we can't access the model for logger::Logger
# using the method syntax
logger_m = OroGen.syskit_model_by_orogen_name("logger::Logger")

module OroGen
    describe logger_m do
        it { is_configurable }
    end
end
