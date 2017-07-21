[![Build Status](https://travis-ci.org/nsidc/vagrant-vsphere.svg?branch=master)](https://travis-ci.org/nsidc/vagrant-vsphere) [![Gem Version](https://badge.fury.io/rb/vagrant-vsphere.svg)](http://badge.fury.io/rb/vagrant-vsphere)

# Vagrant vSphere Provider

This is a [Vagrant](http://www.vagrantup.com) 1.6.4+ plugin that adds a
[vSphere](http://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc_50%2Fright-pane.html)
provider to Vagrant, allowing Vagrant to control and provision machines using
VMware. New machines are created from virtual machines or templates which must
be configured prior to using this provider.

This provider is built on top of the
[RbVmomi](https://github.com/vmware/rbvmomi) Ruby interface to the vSphere API.

## Requirements

* Vagrant 1.6.4+
* VMware with vSphere API
* Ruby 1.9+
* libxml2, libxml2-dev, libxslt, libxslt-dev

## Current Version
**version: 1.12.1**

vagrant-vsphere (**version: 1.12.1**) is available from
[RubyGems.org](https://rubygems.org/gems/vagrant-vsphere)

## Installation

Install using standard Vagrant plugin method:

```bash
vagrant plugin install vagrant-vsphere
```

This will install the plugin from RubyGems.org.

Alternatively, you can clone this repository and build the source with `gem
build vSphere.gemspec`. After the gem is built, run the plugin install command
from the build directory.

### Potential Installation Problems

The requirements for [Nokogiri](http://nokogiri.org/) must be installed before
the plugin can be installed. See the
[Nokogiri tutorial](http://nokogiri.org/tutorials/installing_nokogiri.html) for
detailed instructions.

The plugin forces use of Nokogiri ~> 1.5 to prevent conflicts with older
versions of system libraries, specifically zlib.

## Usage

After installing the plugin, you must create a vSphere box. The example_box
directory contains a metadata.json file that can be used to create a dummy box
with the command:

```bash
tar cvzf dummy.box ./metadata.json
```

This can be installed using the standard Vagrant methods or specified in the
Vagrantfile.

After creating the dummy box, make a Vagrantfile that looks like the following:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = 'dummy'
  config.vm.box_url = './example_box/dummy.box'

  config.vm.provider :vsphere do |vsphere|
    vsphere.host = 'HOST NAME OF YOUR VSPHERE INSTANCE'
    vsphere.compute_resource_name = 'YOUR COMPUTE RESOURCE'
    vsphere.resource_pool_name = 'YOUR RESOURCE POOL'
    vsphere.template_name = '/PATH/TO/YOUR VM TEMPLATE'
    vsphere.name = 'NEW VM NAME'
    vsphere.user = 'YOUR VMWARE USER'
    vsphere.password = 'YOUR VMWARE PASSWORD'
  end
end
```

And then run `vagrant up --provider=vsphere`.

### Custom Box

The bulk of this configuration can be included as part of a custom box. See the
[Vagrant documentation](http://docs.vagrantup.com/v2/boxes.html) and the Vagrant
[AWS provider](https://github.com/mitchellh/vagrant-aws/tree/master/example_box)
for more information and an example.

### Supported Commands

Currently the only implemented actions are `up`, `halt`, `reload`, `destroy`,
and `ssh`.

`up` supports provisioning of the new VM with the standard Vagrant provisioners.

## Configuration

This provider has the following settings, all are required unless noted:

* `host` - string - IP or name for the vSphere API
* `insecure` - _Optional_ boolean - verify SSL certificate from the host
* `user` - string - user name for connecting to vSphere
* `password` - string - password for connecting to vSphere. If no value is given, or the
  value is set to `:ask`, the user will be prompted to enter the password on
  each invocation.
* `data_center_name` - _Optional_ string - datacenter containing the computed resource,
  the template and where the new VM will be created, if not specified the first
  datacenter found will be used
* `compute_resource_name` - string - _Required if cloning from template_ the name of the
  host or cluster containing the resource pool for the new VM
* `resource_pool_name` - string - the resource pool for the new VM. If not supplied, and
  cloning from a template, uses the root resource pool
* `clone_from_vm` - _Optional_ string - use a virtual machine instead of a template as
  the source for the cloning operation
* `template_name` - string - the VM or VM template to clone (including the full folder path)
* `vm_base_path` - _Optional_ string - path to folder where new VM should be created, if
  not specified template's parent folder will be used
* `name` - _Optional_ string - name of the new VM, if missing the name will be auto
  generated
* `customization_spec_name` - _Optional_ string - customization spec for the new VM
* `data_store_name` - _Optional_ string - the datastore where the VM will be located
* `linked_clone` - _Optional_ string - link the cloned VM to the parent to share virtual
  disks
* `proxy_host` - _Optional_ string - proxy host name for connecting to vSphere via proxy
* `proxy_port` - _Optional_ integer - proxy port number for connecting to vSphere via
  proxy
* `memory_mb` - _Optional_ integer - Configure the amount of memory (in MB) for the new VM
* `cpu_count` - _Optional_ integer - Configure the number of CPUs for the new VM
* `cpu_reservation` - _Optional_ integer - Configure the CPU time (in MHz) to reserve for this VM
* `mem_reservation` - _Optional_ integer - Configure the memory (in MB) to reserve for this VM
* `custom_attribute` - _Optional_ hash - Add a
  [custom attribute](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0CB4QFjAAahUKEwiWwbWX59jHAhVBC5IKHa3HAEU&url=http%3A%2F%2Fpubs.vmware.com%2Fvsphere-51%2Ftopic%2Fcom.vmware.vsphere.vcenterhost.doc%2FGUID-25244732-D473-4857-A471-579257B6D95F.html&usg=AFQjCNGTSl4cauFrflUJpBeTBb0Yv7R13g&sig2=a9he6W2qVvBSZ5lCiXnENA)
  to the VM upon creation. This method takes a key/value pair,
  e.g. `vsphere.custom_attribute('timestamp', Time.now.to_s)`, and may be called
  multiple times to set different attributes.
* `extra_config` - _Optional_ hash - A hash of extra configuration values to add to
  the VM during creation. These are of the form `{'guestinfo.some.variable' => 'somevalue'}`,
  where the key must start with `guestinfo.`. VMs with VWware Tools installed can
  retrieve the value of these variables using the `vmtoolsd` command: `vmtoolsd --cmd 'info-get guestinfo.some.variable'`.
* `notes` - _Optional_ string - Add arbitrary notes to the VM
* `wait_for_customization` - _Optional_ boolean - Wait for customization to complete before 
  continuing. Set to false by default. 
* `wait_for_customization_timeout` - _Optional_ integer - Timeout in seconds to wait for 
  customization to complete before continuing. Set to 600 by default.   
* `management_network_adapter_slot` - _Optional_ integer - zero based array of the card index.
  This will be the network card to get the ip address from to use for communication between
  Vagrant and the vm. If this is not set we will use the one detected by VSphere.
* `management_network_adapter_address_family` - _Optional_ string - When auto detecting ip address to use for 
  communication only detect specified ip address family. Possible values are 'ipv4' and 'ipv6'. If this value
  is not set it will use the first ip address detected.
* `destroy_unused_network_interfaces` - _Optional_ boolean - should network cards that have not been configured 
  explicitly, be deleted. If set to false then existing network cards are left alone.
* `network_adapter` - Array of network card configuration
* `disk` - Array of disk configuration
* `destroy_unused_serial_ports` - _Optional_ boolean - should serial ports that have not been configured 
  explicitly, be deleted. If set to false then existing serial ports are left alone.
* `serial_port` - Array of serial port configuration

## Network card configuration
* `slot` - integer - zero based array of the card index
* `allow_guest_control` - _Optional_ boolean - Configure the address type of the
* `connected` - _Optional_ boolean - is the vm network card connected to the network
* `start_connected` - _Optional_ boolean - When VM is turned on should the vm network card be connected to the network
* `vlan` - _Optional_ string - vlan to connect the network card to
* `address_type` - _Optional_ - Configure the address type of the
  [vSphere Virtual Ethernet Card](https://www.vmware.com/support/developer/vc-sdk/visdk2xpubs/ReferenceGuide/vim.vm.device.VirtualEthernetCard.html)
* `mac_address` - _Optional_ string - Used to set the mac address of the network card
* `ip_address` - _Optional_ string - Do not auto detect the ip address for this network card, assume it is the ip
  address specified. Use this when guest tools cannot be installed on the vm. One approach is to specify static mac address 
  for vm and reserve ip address on DHCP server for mac address.
* `wake_on_lan_enabled` - _Optional_ boolean - should vm turn on when magic packet is received on network card

## Disk configuration
* `slot` - integer - zero based array of the disk index
* `size` - integer - the size the disk should be resized to in kibibyte (1024 bytes)

## Serial port configuration
* `yield_on_poll` - _Optional_ boolean - Enables CPU yield behavior. If you set yieldOnPoll to true, the virtual machine will 
  periodically relinquish the processor if its sole task is polling the virtual serial port. The amount of time it takes to 
  regain the processor will depend on the degree of other virtual machine activity on the host.
* `connected` - _Optional_ boolean - is the vm serial port connected
* `start_connected` - _Optional_ boolean - When VM is turned on should the vm serial port be connected
* `backing` - _Optional_ string - The type of serial port backing to use. Possible values are 'uri', 'pipe', 'file', 'device'.
  
  `uri` supports a connection between the virtual machine and a resource on the network. The virtual machine can initiate a connection 
  with the network resource, or it can listen for connections originating from the network. 

  `pipe` supports I/O through a named pipe. The pipe connects the virtual machine to a host application or a virtual machine on the same host. 

  `file` supports output through the virtual serial port to a file on the same host.

  `device` supports a connection between the virtual machine and a device that is connected to a physical serial port on the host.

### uri
* `direction` - _Optional_ string - The direction of the connection. Possible values are 'client' and 'server'
* `proxy_uri` - _Optional_ string - Identifies a proxy service that provides network access to the serviceURI. If you specify 
  a proxy URI, the virtual machine initiates a connection with the proxy service and forwards the serviceURI and direction to the proxy. 
* `service_uri` - _Optional_ string - Identifies the local host or a system on the network, depending on the value of 
  direction. If you use the virtual machine as a server, the URI identifies the host on which the virtual machine 
  runs. In this case, the host name part of the URI should be empty, or it should specify the address of the local host. 
  If you use the virtual machine as a client, the URI identifies the remote system on the network.

### pipe
* `endpoint` - _Optional_ string - Indicates the role the virtual machine assumes as an endpoint for the pipe. 
  Possible values are 'client' and 'server'
* `no_rx_loss` - _Optional_ boolean - Enables optimized data transfer over the pipe. When you use this feature, 
  the ESX server buffers data to prevent data overrun. This allows the virtual machine to read all of the data 
  transferred over the pipe with no data loss. To use optimized data transfer, set noRxLoss to true. To disable 
  this feature, set the property to false.

### file
* `file_name` - _Optional_ string - Filename for the host file used in this backing. 

### device
* `device_name` - _Optional_ string - The name of the device on the host system.  
* `use_auto_detect` - _Optional_ boolean - Indicates whether the device should be auto detected instead of directly specified. If this value is set to TRUE, deviceName is ignored. 

### Cloning from a VM rather than a template

To clone from an existing VM rather than a template, set `clone_from_vm` to
true. If this value is set, `compute_resource_name` and `resource_pool_name` are
not required.

### Template_Name

* The template name includes the actual template name and the directory path
  containing the template.
* **For example:** if the template is a directory called **vagrant-templates**
  and the template is called **ubuntu-lucid-template** the `template_name`
  setting would be:

```
vsphere.template_name = "vagrant-templates/ubuntu-lucid-template"
```

![Vagrant Vsphere Screenshot](https://raw.githubusercontent.com/nsidc/vagrant-vsphere/master/vsphere_screenshot.png)

### VM_Base_Path

* The new vagrant VM will be created in the same directory as the template it
  originated from.
* To create the VM in a directory other than the one where the template was
  located, include the **vm_base_path** setting.
* **For example:** if the machines will be stored in a directory called
  **vagrant-machines** the `vm_base_path` would be:

```
vsphere.vm_base_path = "vagrant-machines"
```

![Vagrant Vsphere Screenshot](https://raw.githubusercontent.com/nsidc/vagrant-vsphere/master/vsphere_screenshot.png)

### Setting a static IP address

To set a static IP, add a private network to your vagrant file:

```ruby
config.vm.network 'private_network', ip: '192.168.50.4'
```

The IP address will only be set if a customization spec name is given. The
customization spec must have network adapter settings configured with a static
IP address(just an unused address NOT the address you want the VM to be). The
config.vm.network line will overwrite the ip in the customization spec with the one you set.
For each private network specified, there needs to be a corresponding network adapter in
the customization spec. An error will be thrown if there are more networks than
adapters.

### Auto name generation

The name for the new VM will be automagically generated from the Vagrant machine
name, the current timestamp and a random number to allow for simultaneous
executions.

This is useful if running Vagrant from multiple directories or if multiple
machines are defined in the Vagrantfile.

### Setting addressType for network adapter

This sets the addressType of the network adapter, for example 'Manual' to
be able to set a manual mac address.
This value may depend on the version of vSphere you use. It may be necessary
to set this in combination with the mac field, in order to set a manual
mac address. For valid values for this field see VirtualEthernetCard api
documentation of vSphere.

```ruby
vsphere.addressType = 'Manual'
```

### Setting the MAC address

To set a static MAC address, add a `vsphere.mac` to your `Vagrantfile`.
In some cases you must also set `vsphere.addressType` (see above)
to make this work:

```ruby
vsphere.mac = '00:50:56:XX:YY:ZZ'
```

Take care to avoid using invalid or duplicate VMware MAC addresses, as this can
easily break networking.

## Troubleshooting

### vCenter
ESXi is not supported. Make sure to connect to a vCenter server and not directly to an ESXi host. [ESXi vs vCenter](http://www.mustbegeek.com/difference-between-vsphere-esxi-and-vcenter/)

### Permissions
If you have permission issues:

1. give the connecting user read only access to everything, and full permission to a specific data center.  Narrow the permissions down after a VM is created.
2. Be sure the path to the VM is correct. see  the "Template_Name" screenshots above for more information.

## Example Usage

### FILE: Vagrantfile

```ruby
VAGRANT_INSTANCE_NAME   = "vagrant-vsphere"

Vagrant.configure("2") do |config|
  config.vm.box     = 'vsphere'
  config.vm.box_url = 'https://vagrantcloud.com/ssx/boxes/vsphere-dummy/versions/0.0.1/providers/vsphere.box'

  config.vm.hostname = VAGRANT_INSTANCE_NAME
  config.vm.define VAGRANT_INSTANCE_NAME do |d|
  end

  config.vm.provider :vsphere do |vsphere|
    vsphere.host                  = 'vsphere.local'
    vsphere.name                  = VAGRANT_INSTANCE_NAME
    vsphere.compute_resource_name = 'vagrant01.vsphere.local'
    vsphere.resource_pool_name    = 'vagrant'
    vsphere.template_name         = 'vagrant-templates/ubuntu14041'
    vsphere.vm_base_path          = "vagrant-machines"

    vsphere.user     = 'vagrant-user@vsphere'
    vsphere.password = '***************'
    vsphere.insecure = true

    vsphere.custom_attribute('timestamp', Time.now.to_s)
  end
end
```

### Vagrant Up

```bash
vagrant up --provider=vsphere
```
### Vagrant SSH

```bash
vagrant ssh
```

### Vagrant Destroy

```bash
vagrant destroy
```

## Version History

See
[`CHANGELOG.md`](https://github.com/nsidc/vagrant-vsphere/blob/master/CHANGELOG.md).

## Contributing

See
[`DEVELOPMENT.md`](https://github.com/nsidc/vagrant-vsphere/blob/master/DEVELOPMENT.md).

## License

The Vagrant vSphere Provider is licensed under the MIT license. See
[LICENSE.txt][license].

[license]: https://raw.github.com/nsidc/vagrant-vsphere/master/LICENSE.txt

## Credit

This software was developed by the National Snow and Ice Data Center with
funding from multiple sources.
