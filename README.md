# Vagrant vSphere Provider

This is a [Vagrant](http://www.vagrantup.com) 1.6.3+ plugin that adds a [vSphere](http://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc_50%2Fright-pane.html)
provider to Vagrant, allowing Vagrant to control and provision machines using VMware. New machines are created from virtual machines or templates which must be configured prior to using using this provider.

This provider is built on top of the [RbVmomi](https://github.com/vmware/rbvmomi) Ruby interface to the vSphere API.

## Requirements
* Vagrant 1.6.3+
* VMware + vSphere API
* Ruby 1.9+
* libxml2, libxml2-dev, libxslt, libxslt-dev

## Current Version
**version: 0.13.0**

vagrant-vsphere (**version: 0.13.0**) is available from [RubyGems.org](https://rubygems.org/gems/vagrant-vsphere)

## Installation

Install using standard Vagrant plugin method:

```
$ vagrant plugin install vagrant-vsphere
```

This will install the plugin from RubyGems.org.

Alternatively, you can clone this repository and build the source with `gem build vSphere.gemspec`.
After the gem is built, run the plugin install command from the build directory.

### Potential Intallation Problems

The requirements for [Nokogiri](http://nokogiri.org/) must be installed before the plugin can be installed. See Nokogiri's [tutorial](http://nokogiri.org/tutorials/installing_nokogiri.html) for
detailed instructions.

The plugin forces use of Nokogiri >= 1.5.10 to prevent conflicts with older versions of system libraries, specifically zlib.

## Usage

After installing the plugin, you must create a vSphere box. The example_box directory contains a metadata.json file
that can be used to create a dummy box with the command:

```
$ tar cvzf dummy.box ./metadata.json
```

This can be installed using the standard Vagrant methods or specified in the Vagrantfile.

After creating the dummy box, make a Vagrantfile that looks like the following:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = 'dummy'
  config.vm.box_url = './example_box/dummy.box'

  config.vm.provider :vsphere do |vsphere|
    vsphere.host = 'HOST NAME OF YOUR VSPHERE INSTANCE'
    vsphere.compute_resource_name = 'YOUR COMPUTE RESOURCE'
    vsphere.resource_pool_name = 'YOUR RESOURCE POOL'
    vsphere.template_name = 'YOUR VM TEMPLATE'
    vsphere.name = 'NEW VM NAME'
    vsphere.user = 'YOUR VMWARE USER'
    vsphere.password = 'YOUR VMWARE PASSWORD'
  end
end
```

And then run `vagrant up --provider=vsphere`.

### Custom Box

The bulk of this configuration can be included as part of a custom box. See the [Vagrant documentation](http://docs.vagrantup.com/v2/boxes.html)
and the Vagrant [AWS provider](https://github.com/mitchellh/vagrant-aws/tree/master/example_box) for more information and an example.

### Supported Commands

Currently the only implemented actions are `up`, `halt`, `destroy`, and `ssh`.

`up` supports provisioning of the new VM with the standard Vagrant provisioners.


## Configuration

This provider has the following settings, all are required unless noted:

* `host` -  IP or name for the vSphere API
* `insecure` - _Optional_ verify SSL certificate from the host
* `user` - user name for connecting to vSphere
* `password` - password  for connecting to vSphere
* `data_center_name` - _Optional_ datacenter containing the computed resource, the template and where the new VM will be created, if not specified the first datacenter found will be used
* `compute_resource_name` - _Required if cloning from template_ the name of the host containing the resource pool for the new VM
* `resource_pool_name` - the resource pool for the new VM. If not supplied, and cloning from a template, uses the root resource pool
* `clone_from_vm` - _Optional_ use a virtual machine instead of a template as the source for the cloning operation
* `template_name` - the VM or VM template to clone
* `vm_base_path` - _Optional_ path to folder where new VM sould be created, if not specified template's parent folder will be used
* `name` - _Optional_ name of the new VM, if missing the name will be auto generated
* `customization_spec_name` - _Optional_ customization spec for the new VM
* `data_store_name` - _Optional_ the datastore where the VM will be located
* `linked_clone` - _Optional_ link the cloned VM to the parent to share virtual disks
* `proxy_host` - _Optional_ proxy host name for connecting to vSphere via proxy
* `proxy_port` - _Optional_ proxy port number for connecting to vSphere via proxy

### Cloning from a VM rather than a template

To clone from an existing VM rather than a template, set `clone_from_vm` to true. If this value is set, `compute_resource_name` and `resource_pool_name` are not required.

### Setting a static IP address

To set a static IP, add a private network to your vagrant file:

```ruby
config.vm.network 'private_network', ip: '192.168.50.4'
```

The IP address will only be set if a customization spec name is given. The customization spec must have network adapter settings configured. For each private network specified, there needs to be a corresponding network adapter in the customization spec. An error  will be thrown if there are more networks than adapters.

### Auto name generation

The name for the new VM will be automagically generated from the Vagrant machine name, the current timestamp and a random number to allow for simultaneous executions.

This is useful if running Vagrant from multiple directories or if multiple machines are defined in the Vagrantfile.

## Version History
* 0.0.1
  * Initial release
* 0.1.0
  * Add folder syncing with guest OS
  * Add provisoning
* 0.2.0
  * Merge halt action from [catharsis](https://github.com/catharsis)
* 0.3.0
  * Lock Nokogiri version at 1.5.10 to prevent library conflicts
  * Add support for customization specs
* 0.4.0
  * Add support for specifying datastore location for new VMs
* 0.5.0
  * Allow setting static ip addresses using Vagrant private networks
  * Allow cloning from VM or template
* 0.5.1
  * fix rsync on Windows, adapted from [mitchellh/vagrant-aws#77](https://github.com/mitchellh/vagrant-aws/pull/77)
* 0.6.0
  * add support for the `vagrant ssh -c` command
* 0.7.0
  * handle multiple private key paths
  * add auto name generation based on machine name
  * add support for linked clones
* 0.7.1
  * fixes rsync error reporting
  * updates locales yaml
  * restricts rbvmomi dependency
* 0.7.2
  * includes template in get_location (from: tim95030 fixes issue #38)
  * updates Gemfile to fall back to old version of vagrant for if ruby < 2.0.0 is available.
* 0.8.0
  * Adds configuration for connecting via proxy server (tkak issue #40)
* 0.8.1
  * Fixes [#47](https://github.com/nsidc/vagrant-vsphere/issues/47) via [olegz-alertlogic #52](https://github.com/nsidc/vagrant-vsphere/pull/52)
* 0.8.2
  * fixes no error messages [#58 leth:no-error-message](https://github.com/nsidc/vagrant-vsphere/pull/58)
  * fixes typo [#57 targetx007](https://github.com/nsidc/vagrant-vsphere/pull/57)
  * fixes additional no error messages
* 0.8.3
  * Fixed "No error message" on rbvmomi method calls. [#74: mkuzmin:rbvmomi-error-messages](https://github.com/nsidc/vagrant-vsphere/pull/74)
* 0.8.4
  * Use root resource pool when cloning from template [#63: matt-richardson:support-resource-pools-on-vsphere-standard-edition](https://github.com/nsidc/vagrant-vsphere/pull/63)
* 0.8.5
  * fixed synced folders to work with WinRM communicator [#72 10thmagnitude:master](https://github.com/nsidc/vagrant-vsphere/pull/72)
* 0.9.0
  * increases Vagrant requirements to 1.6.3+
  * Supports differentiating between SSH/WinRM communicator [#67 marnovdm:feature/waiting-for-winrm](https://github.com/nsidc/vagrant-vsphere/pull/67)
* 0.9.1
  * reuse folder sync code from Vagrant core. [#66 mkuzmin:sync-folders](https://github.com/nsidc/vagrant-vsphere/pull/66)
* 0.9.2
  * Instruct vagrant to set the guest hostname according to Vagrantfile [#69 ddub:set-hostname](https://github.com/nsidc/vagrant-vsphere/pull/69)
* 0.10.0
  * new optional parameter to clone into custom folder in vSphere [#73 mikola-spb:vm-base-path](https://github.com/nsidc/vagrant-vsphere/pull/73)
  * follows semvar better, this adds functionality in a backwards compatible way, so bumps the minor. 0.9.0, should have been a major version.
* 0.11.0
  * Create the VM target folder if it doesn't exist #76 marnovdm:feature/create_vm_folder.
* 0.12.0
  * Use a directory name where Vagrantfile is stored as a prefix for VM name [#82 mkuzmin:name-prefix](https://github.com/nsidc/vagrant-vsphere/pull/82).
* 0.13.0
  * Find and install box file for multi-provider boxes automatically [#86 mkuzmin:install-box](https://github.com/nsidc/vagrant-vsphere/pull/86) & [#87 mkuzmin/provider-name](https://github.com/nsidc/vagrant-vsphere/pull/87).



## Versioning

This plugin follows the principles of [Semantic Versioning 2.0.0](http://semver.org/)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Unit Tests

Please run the unit tests to verify your changes. To do this simply run `rake`.
If you want a quick merge, write a spec that fails before your changes are applied and that passes after.


If you don't have rake installed, first install [bundler](http://bundler.io/) and run `bundle install`.



## License

The Vagrant vSphere Provider is licensed under the MIT license. See [LICENSE.txt][license].

[license]: https://raw.github.com/nsidc/vagrant-vsphere/master/LICENSE.txt

## Credit

This software was developed by the National Snow and Ice Data Center with funding from multiple sources.
