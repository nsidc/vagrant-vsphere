require 'rbvmomi'
require 'i18n'
require 'vSphere/util/vim_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class Destroy
        include Util::VimHelpers

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          destroy_vm env
          env[:machine].id = nil

          @app.call env
        end

        private

        def destroy_vm(env)
          return if env[:machine].state.id == :not_created
          vm = get_vm_by_uuid env[:vSphere_connection], env[:machine]
          return if vm.nil?

          begin
            env[:ui].info I18n.t('vsphere.destroy_vm')
            vm.Destroy_Task.wait_for_completion
          rescue Errors::VSphereError
            raise
          rescue StandardError => e
            raise Errors::VSphereError.new, e.message
          end
        end
      end
    end
  end
end
