require 'rbvmomi'
require 'i18n'
require 'vSphere/util/vim_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class PowerOff
        include Util::VimHelpers

        def initialize(app, env)
          @app = app
        end

        def call(env)
          vm = get_vm_by_uuid env[:vSphere_connection], env[:machine]

          unless vm.nil?
            env[:ui].info I18n.t('vsphere.power_off_vm')
            vm.PowerOffVM_Task.wait_for_completion
          end

          @app.call env
        end
      end
    end
  end
end