# frozen_string_literal: true

using_task_library 'logger'

module OroGen
    describe logger.Logger do
        it { is_configurable }
    end
end
