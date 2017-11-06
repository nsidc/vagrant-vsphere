require 'rbvmomi'
require 'vSphere/util/vim_helpers'
require 'vSphere/util/vm_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class GetState
        include Util::VimHelpers
        include Util::VmHelpers

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:machine_state_id] = get_state(env[:vSphere_connection], env[:machine])

          @app.call env
        end

        private

        def get_state(connection, machine)
          return :not_created  if machine.id.nil?

          vm = get_vm_by_uuid connection, machine

          return :not_created if vm.nil?

          if powered_on?(vm)
            :running
          elsif suspended?(vm)
            :suspended
          else
            :poweroff
          end
        end
      end
    end
  end
end
