require 'vSphere/util/vim_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class Provision < Vagrant::Action::Builtin::Provision
        include Util::VimHelpers

        def call(_env)
          super

          machine = @env[:machine]

          vm = get_vm_by_uuid(@env[:vSphere_connection], machine)

          @env[:ui].info I18n.t('vsphere.set_cust_attrs')

          machine.provider_config.custom_attributes.each do |k, v|
            vm.setCustomValue(key: k, value: v)
          end
        end
      end
    end
  end
end
