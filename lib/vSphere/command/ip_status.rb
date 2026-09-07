require 'optparse'

module VagrantPlugins
  module VSphere
    module Command
      class IpStatus < Vagrant.plugin('2', :command)
        def execute
          opts = OptionParser.new do |o|
            o.banner = 'Usage: vagrant ip-status [name]'
          end

          argv = parse_options(opts)
          return unless argv

          @env.ui.info('Current machine states with IP addresses:')
          @env.ui.info('')
          @env.ui.info(format('%-25s %-15s %s', 'Name', 'State', 'IP Address'))

          with_target_vms(argv, single_target: false) do |machine|
            state = machine.state
            ip = ip_address_for(machine)

            @env.ui.info(format(
              '%-25s %-15s %s',
              machine.name.to_s,
              state.short_description.to_s,
              ip || '-'
            ))
          end

          0
        end

        private

        def ip_address_for(machine)
          return nil unless machine.provider_name.to_s == 'vsphere'
          return nil if machine.state.id == :not_created

          ssh_info = machine.ssh_info
          return nil if ssh_info.nil?

          ssh_info[:host]
        rescue StandardError
          nil
        end
      end
    end
  end
end
