require 'vagrant'
require 'vagrant/action/builder'

module VagrantPlugins
  module VSphere
    module Action
      include Vagrant::Action::Builtin

      # Vagrant commands
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use(ProvisionerCleanup, :before)

          b.use Call, IsRunning do |env, b2|
            if env[:result]
              if env[:force_confirm_destroy]
                b2.use PowerOff
                next
              end

              b2.use Call, GracefulHalt, :poweroff, :running do |env2, b3|
                b3.use PowerOff unless env2[:result]
              end
            end
          end
          b.use Destroy
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, IsRunning do |env2, b3|
              unless env2[:result]
                b3.use MessageNotRunning
                next
              end

              b3.use Provision
              b3.use SyncedFolders
            end
          end
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, IsRunning do |env2, b3|
              unless env2[:result]
                b3.use MessageNotRunning
                next
              end

              b3.use SSHExec
            end
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, IsRunning do |env2, b3|
              unless env2[:result]
                b3.use MessageNotRunning
                next
              end

              b3.use SSHRun
            end
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBox
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if env[:result]
              b2.use MessageAlreadyCreated
              next
            end

            b2.use Clone
          end
          b.use Call, IsRunning do |env, b2|
            b2.use PowerOn unless env[:result]
          end
          b.use WaitForIPAddress
          b.use WaitForCommunicator, [:running]
          b.use Provision
          b.use SyncedFolders
          b.use SetHostname
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Call, IsRunning do |env2, b3|
              unless env2[:result]
                b3.use MessageNotRunning
                next
              end

              b3.use Call, GracefulHalt, :poweroff, :running do |env3, b4|
                b4.use PowerOff unless env3[:result]
              end
            end
          end
        end
      end

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end
            b2.use action_halt
            b2.use action_up
          end
        end
      end


      # TODO: Remove the if guard when Vagrant 1.8.0 is the minimum version.
      # rubocop:disable IndentationWidth
      if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')
      def self.action_snapshot_delete
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if env[:result]
              b2.use SnapshotDelete
            else
              b2.use MessageNotCreated
            end
          end
        end
      end

      def self.action_snapshot_restore
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SnapshotRestore
            b2.use Call, IsEnvSet, :snapshot_delete do |env2, b3|
              # Used by vagrant push/pop
              b3.use action_snapshot_delete if env2[:result]
            end

            b2.use action_up
          end
        end
      end

      def self.action_snapshot_save
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            if env[:result]
              b2.use SnapshotSave
            else
              b2.use MessageNotCreated
            end
          end
        end
      end
      end # Vagrant > 1.8.0 guard
      # rubocop:enable IndentationWidth

      # autoload
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :Clone, action_root.join('clone')
      autoload :Destroy, action_root.join('destroy')
      autoload :IsCreated, action_root.join('is_created')
      autoload :IsRunning, action_root.join('is_running')
      autoload :MessageAlreadyCreated, action_root.join('message_already_created')
      autoload :MessageNotCreated, action_root.join('message_not_created')
      autoload :MessageNotRunning, action_root.join('message_not_running')
      autoload :PowerOff, action_root.join('power_off')
      autoload :PowerOn, action_root.join('power_on')
      autoload :WaitForIPAddress, action_root.join('wait_for_ip_address')

      # TODO: Remove the if guard when Vagrant 1.8.0 is the minimum version.
      # rubocop:disable IndentationWidth
      if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.8.0')
      autoload :SnapshotDelete, action_root.join('snapshot_delete')
      autoload :SnapshotRestore, action_root.join('snapshot_restore')
      autoload :SnapshotSave, action_root.join('snapshot_save')
      end
      # rubocop:enable IndentationWidth
    end
  end
end
