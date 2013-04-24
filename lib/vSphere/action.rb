require 'vagrant'
require 'vagrant/action/builder'

module VagrantPlugins
  module VSphere
    module Action
      include Vagrant::Action::Builtin

      #Vagrant actions
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHExec
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if !env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHRun
          end
        end
      end

	    def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectVSphere
          b.use Call, IsCreated do |env, bb|
            if !env[:result]
              bb.use Clone
            end
          end
          b.use CloseVSphere
        end
      end

      #vSphere specific actions
      def self.action_get_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectVSphere
          b.use GetState
          b.use CloseVSphere
        end
      end

      def self.action_get_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectVSphere
          b.use GetSshInfo
          b.use CloseVSphere
        end
      end
    end
  end
end

