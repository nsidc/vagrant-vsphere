require 'ipaddr'
require 'timeout'

module VagrantPlugins
  module VSphere
    module Action
      class WaitForIPAddress
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          machine = env[:machine]
          driver = machine.provider.driver
          timeout = machine.provider_config.ip_address_timeout

          env[:ui].output('Waiting for the machine to report its IP address...')
          env[:ui].detail("Timeout: #{timeout} seconds")

          guest_ip = nil

          fail Errors::VSphereError, :wait_for_ip_address_timeout unless driver.is_created

          Timeout.timeout(timeout) do
            loop do
              # If a ctrl-c came through, break out
              return if env[:interrupted]

              if driver.is_running
                ssh_info = driver.ssh_info

                if ssh_info.nil?
                  env[:ui].info("Waiting for ip address")
                else
                  guest_ip = ssh_info[:host]
    
                  begin
                    IPAddr.new(guest_ip)
                    break
                  rescue IPAddr::InvalidAddressError
                    # Ignore, continue looking.
                    env[:ui].warn("Invalid IP address returned: #{guest_ip}")  
                  end
                end
              else
                env[:ui].warn("Machine is not running")
              end

              sleep 1
            end
          end

          # If we were interrupted then return now
          return if env[:interrupted]

          env[:ui].detail("IP: #{guest_ip}")

          @app.call(env)
        rescue Timeout::Error
          fail Errors::VSphereError, :wait_for_ip_address_timeout
        end
      end
    end
  end
end
