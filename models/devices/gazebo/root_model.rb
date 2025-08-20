# frozen_string_literal: true

require "common_models/models/devices/gazebo/model"
require "common_models/models/devices/gazebo/link"

module CommonModels
    module Devices
        module Gazebo
            device_type "RootModel" do # rubocop:disable Metrics/BlockLength
                provides Model

                extend_device_configuration do # rubocop:disable Metrics/BlockLength
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

                    # This method merges all the exported sdf links, joints and submodels
                    # in a single instance requirement. The main usage is to simplify
                    # running the model task alongside all the devices that were defined
                    # for a master device instance.
                    #
                    # This is especially useful when using the read_only functionality on
                    # another ModelTask, as one usually needs some links from a read
                    # only model, and calling this on both sides ensures that no exported
                    # devices are forgotten.
                    #
                    # @example
                    # Robot.actions do
                    #     ...
                    #     use_profile do
                    #         define("gazebo_root",
                    #                Profiles::Gazebo::Base.robot
                    #               .base_model_dev.gazebo_root_model
                    #               .fully_instanciated_model)
                    #     end
                    # end
                    #
                    # Robot.controller do
                    #     Robot.gazebo_root_def!
                    # end
                    def fully_instanciated_model
                        ir = to_instance_requirements
                        each_submodel do |m|
                            ir.merge(m.to_instance_requirements.to_component_model)
                        end
                        each_exported_link do |m|
                            ir.merge(m.to_instance_requirements.to_component_model)
                        end
                        each_exported_joint do |m|
                            ir.merge(m.to_instance_requirements.to_component_model)
                        end
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
