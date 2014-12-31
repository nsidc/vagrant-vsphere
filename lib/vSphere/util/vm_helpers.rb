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
      end
    end
  end
end
