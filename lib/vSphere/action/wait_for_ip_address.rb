require 'ipaddr'
require 'timeout'

module VagrantPlugins
  module VSphere
    module Action
      class WaitForIPAddress
        def initialize(app, _env)
          @app = app
          @logger = Log4r::Logger.new('vagrant::vsphere::wait_for_ip_addr')
        end

        def call(env)
          timeout = env[:machine].provider_config.ip_address_timeout

          env[:ui].output('Waiting for the machine to report its IP address...')
          env[:ui].detail("Timeout: #{timeout} seconds")

          guest_ip = nil
          Timeout.timeout(timeout) do
            loop do
              # If a ctrl-c came through, break out
              return if env[:interrupted]

              guest_ip = nil

              if env[:machine].state.id == :running
                ssh_info = env[:machine].ssh_info
                guest_ip = ssh_info[:host] unless ssh_info.nil?
              end

              if guest_ip
                begin
                  IPAddr.new(guest_ip)
                  break
                rescue IPAddr::InvalidAddressError
                  # Ignore, continue looking.
                  @logger.warn("Invalid IP address returned: #{guest_ip}")
                end
              end

              sleep 1
            end
          end

          # If we were interrupted then return now
          return if env[:interrupted]

          env[:ui].detail("IP: #{guest_ip}")

          @app.call(env)
        rescue Timeout::Error
          raise Errors::VSphereError, :wait_for_ip_address_timeout
        end
      end
    end
  end
end
