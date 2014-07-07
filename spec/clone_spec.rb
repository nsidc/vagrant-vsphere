require 'spec_helper'

describe VagrantPlugins::VSphere::Action::Clone do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it 'should create a CloneVM task' do
    call
    @template.should have_received(:CloneVM_Task).with({
      :folder => @data_center,
      :name => NAME,
      :spec => {:location => {:pool => @child_resource_pool} }
    })
  end

  it 'should set the machine id to be the new UUID' do
    call
    @machine.should have_received(:id=).with(NEW_UUID)
  end

  it 'should call the next item in the middleware stack' do
    call
    @app.should have_received :call
  end

  it 'should set static IP when given config spec' do
    @machine.provider_config.stub(:customization_spec_name).and_return('spec')
    call
    @ip.should have_received(:ipAddress=).with('0.0.0.0')
  end

  it 'should use root resource pool when cloning from template and no resource pool specified' do
    @machine.provider_config.stub(:resource_pool_name).and_return(nil)
    call
    @template.should have_received(:CloneVM_Task).with({
      :folder => @data_center,
      :name => NAME,
      :spec => {:location => {:pool => @root_resource_pool } }
    })
  end
end