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

        # https://www.vmware.com/support/developer/converter-sdk/conv61_apireference/vim.VirtualMachine.html#powerOn
        def resume_vm(vm)
          vm.PowerOnVM_Task.wait_for_completion
        end

        def suspend_vm(vm)
          vm.SuspendVM_Task.wait_for_completion
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

        # Create a named snapshot on a given VM
        #
        # This method creates a named snapshot on the given VM. This method
        # blocks until the snapshot creation task is complete. An optional
        # block can be passed which is used to report progress.
        #
        # @param vm [RbVmomi::VIM::VirtualMachine]
        # @param name [String]
        # @yield [Integer] Percentage complete as an integer. Called multiple
        #   times.
        #
        # @return [void]
        def create_snapshot(vm, name)
          task = vm.CreateSnapshot_Task(
            name: name,
            memory: false,
            quiesce: false)

          if block_given?
            task.wait_for_progress do |progress|
              yield progress unless progress.nil?
            end
          else
            task.wait_for_completion
          end
        end

        # Delete a named snapshot on a given VM
        #
        # This method deletes a named snapshot on the given VM. This method
        # blocks until the snapshot deletion task is complete. An optional
        # block can be passed which is used to report progress.
        #
        # @param vm [RbVmomi::VIM::VirtualMachine]
        # @param name [String]
        # @yield [Integer] Percentage complete as an integer. Called multiple
        #   times.
        #
        # @return [void]
        def delete_snapshot(vm, name)
          snapshot = enumerate_snapshots(vm).find { |s| s.name == name }

          # No snapshot matching "name"
          return nil if snapshot.nil?

          task = snapshot.snapshot.RemoveSnapshot_Task(removeChildren: false)

          if block_given?
            task.wait_for_progress do |progress|
              yield progress unless progress.nil?
            end
          else
            task.wait_for_completion
          end
        end

        # Restore a VM to a named snapshot
        #
        # This method restores a VM to the named snapshot state. This method
        # blocks until the restoration task is complete. An optional block can
        # be passed which is used to report progress.
        #
        # @param vm [RbVmomi::VIM::VirtualMachine]
        # @param name [String]
        # @yield [Integer] Percentage complete as an integer. Called multiple
        #   times.
        #
        # @return [void]
        def restore_snapshot(vm, name)
          snapshot = enumerate_snapshots(vm).find { |s| s.name == name }

          # No snapshot matching "name"
          return nil if snapshot.nil?

          task = snapshot.snapshot.RevertToSnapshot_Task(suppressPowerOn: true)

          if block_given?
            task.wait_for_progress do |progress|
              yield progress unless progress.nil?
            end
          else
            task.wait_for_completion
          end
        end
      end
    end
  end
end
