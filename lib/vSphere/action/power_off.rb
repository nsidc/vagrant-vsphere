require 'rbvmomi'
require 'i18n'

module VagrantPlugins
  module VSphere
    module Action
      class PowerOff
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          driver = env[:machine].provider.driver
          # If the vm is suspended, we need to turn it on so that we can turn it off.
          # This may seem counterintuitive, but the vsphere API documentation states
          # that the Power Off task for a VM will fail if the state is not poweredOn
          # see: https://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.VirtualMachine.html#powerOff
          if driver.suspended?
            env[:ui].info I18n.t('vsphere.power_on_vm')
            driver.power_on_vm
          end

          # Powering off is a no-op if we can't find the VM or if it is already off
          unless driver.powered_off?.nil? || driver.powered_off?
            env[:ui].info I18n.t('vsphere.power_off_vm')
            driver.power_off_vm
          end

          @app.call env
        end
      end
    end
  end
end
