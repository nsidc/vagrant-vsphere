require 'rbvmomi'
require 'i18n'
require 'vSphere/util/vim_helpers'
require 'vSphere/util/machine_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class PowerOn
        include Util::VimHelpers
        include Util::MachineHelpers

        def initialize(app, env)
          @app = app
        end

        def call(env)
          vm = get_vm_by_uuid env[:vSphere_connection], env[:machine]

          env[:ui].info I18n.t('vsphere.power_on_vm')
          vm.PowerOnVM_Task.wait_for_completion
          
          # wait for SSH to be available 
          wait_for_ssh env
          
          @app.call env
        end
      end
    end
  end
end
