require 'rbvmomi'
require 'i18n'
require 'vSphere/util/vim_helpers'
require 'vSphere/util/vm_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class Suspend
        include Util::VimHelpers
        include Util::VmHelpers

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          vm = get_vm_by_uuid env[:vSphere_connection], env[:machine]

          # Suspending is a no-op if we can't find the VM or it is already off
          # or suspended
          unless vm.nil? || suspended?(vm) || powered_off?(vm)
            env[:ui].info I18n.t('vsphere.suspend_vm')
            suspend_vm(vm)
          end

          @app.call env
        end
      end
    end
  end
end
