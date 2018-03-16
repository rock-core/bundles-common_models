require 'common_models/models/blueprints/map_gen/map_generator_srv'

module Rock
    module MapGen
        # This class implements basic handling for map generation pipelines
        #
        # So far, it handles map generators that also provide the OneShotSrv 
        class PipelineBase < Syskit::Composition
            add MapGeneratorSrv, :as => 'map_source'

            specialize map_source_child => OneShotSrv do
                provides OneShotSrv, :as => 'one_shot'
            end

            def self.instanciate(*args)
                task = super
                if task.fullfills?(OneShotSrv)
                    source_child = task.map_source_child
                    task.each_child do |child|
                        next if child == source_child
                        source_child.should_start_after child.start_event
                    end
                end
                task
            end
        end
    end
end

