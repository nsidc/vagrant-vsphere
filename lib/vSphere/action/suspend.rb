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

          # Powering off is a no-op if we can't find the VM or if it is already off
          unless vm.nil? || powered_off?(vm) || suspended?(vm)
            env[:ui].info I18n.t('vsphere.suspend_vm')
            suspend_vm(vm) do |progress|
              env[:ui].clear_line
              env[:ui].report_progress(progress, 100, false)
            end
          end

          @app.call env
        end
      end
    end
  end
end
