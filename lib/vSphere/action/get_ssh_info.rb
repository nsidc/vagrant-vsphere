require 'rbvmomi'
require 'vSphere/util/vim_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class GetSshInfo
        include Util::VimHelpers

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:machine_ssh_info] = get_ssh_info(env[:vSphere_connection], env[:machine])

          @app.call env
        end

        private

        def get_ssh_info(connection, machine)
          return nil if machine.id.nil?

          vm = get_vm_by_uuid connection, machine

          return nil if vm.nil?
          return nil if vm.guest.ipAddress.nil? || vm.guest.ipAddress.empty?
          {
            host: vm.guest.ipAddress,
            port: 22
          }
        end
      end
    end
  end
end
