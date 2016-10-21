require 'rbvmomi'
require 'i18n'

module VagrantPlugins
  module VSphere
    module Action
      class Clone
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          machine = env[:machine]
          config = machine.provider_config
          driver = machine.provider.driver

          env[:ui].info "Setting custom address: #{config.addressType}" unless config.addressType.nil?
          env[:ui].info "Setting custom mac: #{config.mac}" unless config.mac.nil?
          env[:ui].info "Setting custom vlan: #{config.vlan}" unless config.vlan.nil?
          env[:ui].info "Setting custom memory: #{config.memory_mb}" unless config.memory_mb.nil?
          env[:ui].info "Setting custom cpu count: #{config.cpu_count}" unless config.cpu_count.nil?
          env[:ui].info "Setting custom cpu reservation: #{config.cpu_reservation}" unless config.cpu_reservation.nil?
          env[:ui].info "Setting custom memmory reservation: #{config.mem_reservation}" unless config.mem_reservation.nil?

          config.custom_attributes.each do |k, v|
            env[:ui].info "Setting custom attribute: #{k}=#{v}"
          end

          driver.clone(env[:root_path]) do |progress|
            env[:ui].clear_line
            env[:ui].report_progress(progress, 100, false)
          end

          env[:ui].info I18n.t('vsphere.vm_clone_success')
          @app.call env
        end
      end
    end
  end
end
