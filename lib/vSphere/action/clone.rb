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

          machine.ui.info "Setting custom address: #{config.addressType}" unless config.addressType.nil?
          machine.ui.info "Setting custom mac: #{config.mac}" unless config.mac.nil?
          machine.ui.info "Setting custom vlan: #{config.vlan}" unless config.vlan.nil?
          machine.ui.info "Setting custom memory: #{config.memory_mb}" unless config.memory_mb.nil?
          machine.ui.info "Setting custom cpu count: #{config.cpu_count}" unless config.cpu_count.nil?
          machine.ui.info "Setting custom cpu reservation: #{config.cpu_reservation}" unless config.cpu_reservation.nil?
          env[:ui].info "Setting custom memmory reservation: #{config.mem_reservation}" unless config.mem_reservation.nil?

          config.custom_attributes.each do |k, v|
            machine.ui.info "Setting custom attribute: #{k}=#{v}"
          end

          driver.clone(env[:root_path]) do |progress|
            machine.ui.clear_line
            machine.ui.report_progress(progress, 100, false)
          end

          machine.ui.info I18n.t('vsphere.vm_clone_success')
          @app.call env
        end
      end
    end
  end
end
