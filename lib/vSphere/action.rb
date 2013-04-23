require 'vagrant'
require 'vagrant/action/builder'

module VagrantPlugins
  module VSphere
    module Action
      include Vagrant::Action::Builtin
	  
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
    end
  end
end

