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

        def filter_guest_nic(vm, machine)
          return vm.guest.ipAddress unless machine.provider_config.real_nic_ip

          interfaces = vm.guest.net.select { |g| g.deviceConfigId > 0 }
          ip_addresses = interfaces.map do |i|
            begin
              i.ipConfig.ipAddress.select { |a| a.state == 'preferred' }
            rescue NoMethodError
              nil
            end
          end.flatten.compact

          return (vm.guest.ipAddress || nil) if ip_addresses.empty?

          fail Errors::VSphereError.new, :'multiple_interface_with_real_nic_ip_set' if ip_addresses.size > 1
          ip_addresses.first.ipAddress
        end

        def get_ssh_info(connection, machine)
          return nil if machine.id.nil?

          vm = get_vm_by_uuid connection, machine
          return nil if vm.nil?
          ip_address = filter_guest_nic(vm, machine)
          return nil if ip_address.nil? || ip_address.empty?
          {
            host: ip_address,
            port: 22
          }
        end
      end
    end
  end
end
