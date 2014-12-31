require 'rbvmomi'
require 'i18n'
require 'vSphere/util/vim_helpers'
require 'vSphere/util/vm_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class PowerOff
        include Util::VimHelpers
        include Util::VmHelpers

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          vm = get_vm_by_uuid env[:vSphere_connection], env[:machine]

          # If the vm is suspended, we need to turn it on so that we can turn it off.
          # This may seem counterintuitive, but the vsphere API documentation states
          # that the Power Off task for a VM will fail if the state is not poweredOn
          # see: https://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.VirtualMachine.html#powerOff
          if suspended?(vm)
            env[:ui].info I18n.t('vsphere.power_on_vm')
            power_on_vm(vm)
          end

          # Powering off is a no-op if we can't find the VM or if it is already off
          unless vm.nil? || powered_off?(vm)
            env[:ui].info I18n.t('vsphere.power_off_vm')
            power_off_vm(vm)
          end

          @app.call env
        end
      end
    end
  end
end
