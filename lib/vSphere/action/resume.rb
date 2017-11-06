require 'rbvmomi'
require 'i18n'
require 'vSphere/util/vim_helpers'
require 'vSphere/util/vm_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class Resume
        include Util::VimHelpers
        include Util::VmHelpers

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          vm = get_vm_by_uuid env[:vSphere_connection], env[:machine]

          if suspended?(vm)
            env[:ui].info I18n.t('vsphere.resume_vm')
            resume_vm(vm)
          end

          @app.call env
        end
      end
    end
  end
end
