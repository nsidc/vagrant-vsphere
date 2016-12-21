require 'rbvmomi'
require 'vSphere/util/vim_helpers'
require 'netaddr'

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
          ssh_cidr = machine.provider_config.ssh_cidr
          if ssh_cidr.nil?
            return vm.guest.ipAddress unless machine.provider_config.real_nic_ip
            ip_addresses = vm.guest.net.select { |g| g.deviceConfigId > 0 }.map { |g| g.ipAddress[0] }
            fail Errors::VSphereError.new, :'multiple_interface_with_real_nic_ip_set' if ip_addresses.size > 1
            return ip_addresses.first
          else
            ssh_ips = NetAddr::CIDR.create(ssh_cidr).enumerate
            vm.guest.net.each do |nic_info|
              nic_info.ipAddress.each do |ip|
                return ip if ssh_ips.include?(ip)
              end
            end
          end
          return nil
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
