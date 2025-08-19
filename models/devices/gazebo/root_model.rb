# frozen_string_literal: true

require "common_models/models/devices/gazebo/model"
require "common_models/models/devices/gazebo/link"

module CommonModels
    module Devices
        module Gazebo
            device_type "RootModel" do
                provides Model

                extend_device_configuration do
                    def register_submodel(device)
                        (@submodels ||= []) << device
                    end

                    def each_submodel(&block)
                        (@submodels || []).each(&block)
                    end

                    def register_exported_joint(device)
                        (@exported_joints ||= []) << device
                    end

                    def each_exported_joint(&block)
                        (@exported_joints || []).each(&block)
                    end

                    def register_exported_link(device)
                        (@exported_links ||= []) << device
                    end

                    def each_exported_link(&block)
                        (@exported_links || []).each(&block)
                    end

                    def fully_instanciated_model
                        ir = to_instance_requirements
                        each_submodel { |m| ir = ir.merge(m.to_instance_requirements) }
                        each_exported_link { |m| ir = ir.merge(m.to_instance_requirements) }
                        each_exported_joint { |m| ir = ir.merge(m.to_instance_requirements) }
                        ir
                    end
                end

                input_port "model_pose", "/base/samples/RigidBodyState"

                provides Services::Pose
                provides Services::Velocity,
                         "velocity_samples" => "pose_samples"
            end
        end
    end
end
