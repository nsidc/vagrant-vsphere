require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Util
      module VmState
        POWERED_ON = 'poweredOn'
        POWERED_OFF = 'poweredOff'
        SUSPENDED = 'suspended'
      end

      module VmHelpers
        def power_on_vm(vm)
          vm.PowerOnVM_Task.wait_for_completion
        end

        def power_off_vm(vm)
          vm.PowerOffVM_Task.wait_for_completion
        end

        def get_vm_state(vm)
          vm.runtime.powerState
        end

        def powered_on?(vm)
          get_vm_state(vm).eql?(VmState::POWERED_ON)
        end

        def powered_off?(vm)
          get_vm_state(vm).eql?(VmState::POWERED_OFF)
        end

        def suspended?(vm)
          get_vm_state(vm).eql?(VmState::SUSPENDED)
        end

        # Enumerate VM snapshot tree
        #
        # This method returns an enumerator that performs a depth-first walk
        # of the VM snapshot grap and yields each VirtualMachineSnapshotTree
        # node.
        #
        # @param vm [RbVmomi::VIM::VirtualMachine]
        #
        # @return [Enumerator<RbVmomi::VIM::VirtualMachineSnapshotTree>]
        def enumerate_snapshots(vm)
          snapshot_info = vm.snapshot

          if snapshot_info.nil?
            snapshot_root = []
          else
            snapshot_root = snapshot_info.rootSnapshotList
          end

          recursor = lambda do |snapshot_list|
            Enumerator.new do |yielder|
              snapshot_list.each do |s|
                # Yield the current VirtualMachineSnapshotTree object
                yielder.yield s

                # Recurse into child VirtualMachineSnapshotTree objects
                children = recursor.call(s.childSnapshotList)
                loop do
                  yielder.yield children.next
                end
              end
            end
          end

          recursor.call(snapshot_root)
        end
      end
    end
  end
end
