require 'vSphere/util/vim_helpers'
require 'vSphere/util/vm_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class SnapshotList
        include Util::VimHelpers
        include Util::VmHelpers

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          vm = get_vm_by_uuid(env[:vSphere_connection], env[:machine])

          env[:machine_snapshot_list] = enumerate_snapshots(vm).map(&:name)

          @app.call env
        end
      end
    end
  end
end
