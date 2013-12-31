require 'i18n'
require "vagrant/util/subprocess"
require "vagrant/util/scoped_hash_override"
require "vagrant/util/which"

module VagrantPlugins
  module VSphere
    module Action
      # This middleware uses `rsync` to sync the folders over to the vSphere instance
      # Borrowed from the Vagrant AWS gem, see https://github.com/mitchellh/vagrant-aws/blob/master/lib/vagrant-aws/action/sync_folders.rb 
      class SyncFolders
        include Vagrant::Util::ScopedHashOverride

        def initialize(app, env)
          @app    = app
        end

        def call(env)
          @app.call(env)
          
          ssh_info = env[:machine].ssh_info

          env[:machine].config.vm.synced_folders.each do |id, data|
            data = scoped_hash_override(data, :vsphere)

            # Ignore disabled shared folders
            next if data[:disabled]

            unless Vagrant::Util::Which.which('rsync')
              env[:ui].warn(I18n.t('errors.rsync_not_found'))
              break
            end
            hostpath  = File.expand_path(data[:hostpath], env[:root_path])
            guestpath = data[:guestpath]

            # Make sure there is a trailing slash on the host path to
            # avoid creating an additional directory with rsync
            hostpath = "#{hostpath}/" if hostpath !~ /\/$/

            # on windows rsync.exe requires cygdrive-style paths
            if Vagrant::Util::Platform.windows?
              hostpath = hostpath.gsub(/^(\w):/) { "/cygdrive/#{$1}" }
            end

            env[:ui].info(I18n.t("vsphere.rsync_folder",
                                :hostpath => hostpath,
                                :guestpath => guestpath))
            
            # Create the guest path
            env[:machine].communicate.sudo("mkdir -p '#{guestpath}'")
            env[:machine].communicate.sudo("chown #{ssh_info[:username]} '#{guestpath}'")

            # Rsync over to the guest path using the SSH info
            command = [
              "rsync", "--verbose", "--archive", "-z",
              "--exclude", ".vagrant/",
              "-e", "ssh -p #{ssh_info[:port]} -o StrictHostKeyChecking=no #{get_private_key_options ssh_info}",
              hostpath,
              "#{ssh_info[:username]}@#{ssh_info[:host]}:#{guestpath}"]
            

            # we need to fix permissions when using rsync.exe on windows, see
            # http://stackoverflow.com/questions/5798807/rsync-permission-denied-created-directories-have-no-permissions
            if Vagrant::Util::Platform.windows?
              command.insert(1, "--chmod", "ugo=rwX")
            end

            r = Vagrant::Util::Subprocess.execute(*command)
            if r.exit_code != 0
              raise Errors::RsyncError,
                :guestpath => guestpath,
                :hostpath => hostpath,
                :stderr => r.stderr
            end            
          end
        end
        
        private
        
        def get_private_key_options(ssh_info)
          if ssh_info[:private_key_path].is_a? String
            build_key_option ssh_info[:private_key_path] 
          elsif ssh_info[:private_key_path].is_a? Array
            ssh_info[:private_key_path].map { |path| build_key_option path }.join(' ')
          end
        end
        
        def build_key_option(key)
          "-i '#{key}'"
        end
      end
    end
  end
end
