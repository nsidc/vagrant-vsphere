require 'spec_helper'

CUSTOM_VM_FOLDER = 'custom_vm_folder'

describe VagrantPlugins::VSphere::Action::Clone do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it "should create a CloneVM task with template's parent" do
    call    
    @template.should have_received(:CloneVM_Task).with({
      :folder => @data_center,
      :name => NAME,
      :spec => {}
    })
  end

  it 'should create a CloneVM task with custom folder when given vm base path' do
    custom_base_folder = double(CUSTOM_VM_FOLDER)
    @machine.provider_config.stub(:vm_base_path).and_return(CUSTOM_VM_FOLDER)
    @data_center.vmFolder.stub(:traverse).with(CUSTOM_VM_FOLDER, RbVmomi::VIM::Folder).and_return(custom_base_folder)
    call
    @template.should have_received(:CloneVM_Task).with({
      :folder => custom_base_folder,
      :name => NAME,
      :spec => {}
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
end