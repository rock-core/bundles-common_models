# frozen_string_literal: true

require 'models/compositions/acquire'

module CommonModels
    module Compositions
        class AcquireSpec < Syskit::Test::ComponentTest
            before do
                @srv_m = Syskit::DataService.new_submodel do
                    output_port 'out', '/double'
                end
                @cmp_m = Compositions.Acquire(@srv_m)
            end

            it 'generates a composition model with the service as the data source child' do
                assert @cmp_m.data_source_child.fullfills?(@srv_m)
            end

            it 'emits the success event with the received sample' do
                cmp = syskit_stub_deploy_configure_and_start(@cmp_m)
                event = expect_execution do
                    syskit_write cmp.data_source_child.out_port, 42
                end.to do
                    emit cmp.success_event
                end
                assert_equal({ out: 42 }, event.context.first)
            end

            it 'does not emit anything if there is no sample' do
                cmp = syskit_stub_deploy_configure_and_start(@cmp_m)
                expect_execution.timeout(0.05)
                                .to { not_emit cmp.success_event }
            end

            it 'deals with services that have multiple ports' do
                srv_m = Syskit::DataService.new_submodel do
                    output_port 'out1', '/double'
                    output_port 'out2', '/double'
                end

                cmp_m = Compositions.Acquire(srv_m)
                cmp = syskit_stub_deploy_configure_and_start(cmp_m)
                out1_port = cmp.data_source_child.out1_port
                out2_port = cmp.data_source_child.out2_port

                expect_execution { syskit_write out1_port, 42 }
                    .timeout(0.05)
                    .to { not_emit cmp.success_event }
                event = expect_execution { syskit_write out2_port, 21 }
                        .timeout(0.05)
                        .to { emit cmp.success_event }

                assert_equal({ out1: 42, out2: 21 }, event.context.first)
            end
        end
    end
end
