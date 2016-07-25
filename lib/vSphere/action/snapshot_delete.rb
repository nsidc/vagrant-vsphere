require 'vSphere/util/vim_helpers'
require 'vSphere/util/vm_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class SnapshotDelete
        include Util::VimHelpers
        include Util::VmHelpers

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          vm = get_vm_by_uuid(env[:vSphere_connection], env[:machine])

          env[:ui].info(I18n.t(
            "vagrant.actions.vm.snapshot.deleting",
            name: env[:snapshot_name]))

          delete_snapshot(vm, env[:snapshot_name]) do |progress|
            env[:ui].clear_line
            env[:ui].report_progress(progress, 100, false)
          end

          env[:ui].clear_line

          env[:ui].info(I18n.t(
            "vagrant.actions.vm.snapshot.deleted",
            name: env[:snapshot_name]))

          @app.call env
        end
      end
    end
  end
end
