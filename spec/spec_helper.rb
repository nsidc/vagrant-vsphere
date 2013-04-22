require 'rspec-spies'
require 'rbvmomi'
require 'vSphere/errors'

VIM = RbVmomi::VIM

FOUND_VM = 'found_vm'
MISSING_VM = 'missing_vm'

RSpec.configure do |config|
  config.before(:each) do
    @app = double 'app', :call => true
    @env = {
        :machine => double('machine', :provider_config => double(:host => 'testhost.com', :user => 'testuser', :password => 'testpassword'))
    }

    data_center = double 'data_center'
    data_center.stub(:find_vm).with(FOUND_VM).and_return(true)
    data_center.stub(:find_vm).with(MISSING_VM).and_return(nil)

    service_instance = double 'service_instance', :find_datacenter => data_center

    @vim = double 'vim', :serviceInstance => service_instance

    VIM.stub(:connect).and_return(@vim)
  end
end
