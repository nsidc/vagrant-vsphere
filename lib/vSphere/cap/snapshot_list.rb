module VagrantPlugins
  module VSphere
    module Cap
      module SnapshotList
        # Returns a list of the snapshots that are taken on this machine.
        #
        # @return [Array<String>] Snapshot Name
        def self.snapshot_list(machine)
          machine.driver.snapshot_list
        end
      end
    end
  end
end
