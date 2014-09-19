require 'rbvmomi'
require 'i18n'
require 'vSphere/util/vim_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class Destroy
        include Util::VimHelpers

        def initialize(app, env)
          @app = app
        end

        def call(env)
          destroy_vm env
          env[:machine].id = nil

          @app.call env
        end

        private 
        
        def destroy_vm(env)
          vm = get_vm_by_uuid env[:vSphere_connection], env[:machine]
          return if vm.nil?

          begin
            env[:ui].info I18n.t('vsphere.destroy_vm')
            vm.Destroy_Task.wait_for_completion
          rescue Errors::VSphereError => e
            raise
          rescue Exception => e
            raise Errors::VSphereError.new, e.message
          end
        end
      end
    end
  end
end