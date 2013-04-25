require 'rbvmomi'
require 'i18n'
require 'vSphere/action/vim_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class Clone
        include VimHelpers

        def initialize(app, env)
          @app = app
        end

        def call(env)
          config = env[:machine].provider_config

          dc = get_datacenter env[:vSphere_connection], config
          template = dc.find_vm config.template_name

          raise Error::VSphereError, :message => I18n.t('errors.missing_template') if template.nil?

          begin
            spec = RbVmomi::VIM.VirtualMachineCloneSpec :location => RbVmomi::VIM.VirtualMachineRelocateSpec, :powerOn => true, :template => false

            env[:ui].info I18n.t('vsphere.creating_cloned_vm')
            env[:ui].info " -- Template VM: #{config.template_name}"
            env[:ui].info " -- Name: #{config.name}"

            new_vm = template.CloneVM_Task(:folder => template.parent, :name => config.name, :spec => spec).wait_for_completion
          rescue Exception => e
            raise Errors::VSphereError, :message => e.message
          end

          #TODO: handle interrupted status in the environment, should the vm be destroyed?

          env[:machine].id = new_vm.config.uuid

          @app.call env
        end
      end
    end
  end
end