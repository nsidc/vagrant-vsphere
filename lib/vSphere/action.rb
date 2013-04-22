require 'vagrant'
require 'vagrant/action/builder'

module VagrantPlugins
  module VSphere
    class Action
      include Vagrant::Action::Builtin
	  
	    def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConnectVSphere
        end
      end
    end
  end
end

