# Vagrant vSphere Provider

This is a [Vagrant](http://www.vagrantup.com) 1.2+ plugin that adds a [vSphere](http://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc_50%2Fright-pane.html)
provider to Vagrant, allowing Vagrant to control and provision machines using VMware. New machines are created from VMware templates which must be configured prior to using using
this provider.

This provider is built on top of the [RbVmomi](https://github.com/rlane/rbvmomi) Ruby interface to the vSphere API.

## Requirements
* Vagrant 1.2+
* VMware + vSphere API
* Ruby 1.9+

## Building the gem

The gem needs to be built and installed before the provider can be added to Vagrant:

```
gem build vShpere.gemspec
gem install vagrant-vsphere-VERSION.gem
```

## Installation

Install using standard Vagrant plugin method:

```
$ vagrant plugin install vagrant-vsphere
```

## Usage

After installing the plugin, you must create a vSphere box. The example_box directory contains a metadata.json file
that can be used to create a dummy box with the command:

```
$ tar cvzf dummy.box ./metadata.json
```

This can be installed using the standard Vagrant methods or specified in the Vagrantfile.

After creating the dummy box, make a Vagrantfile that looks like the following:

```
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

Currently the only implemented actions are `up`, `destroy`, and `ssh`.

`up` does not yet support provisioning of the new VM.


## Configuration

This provider has the following settings, all are required unless noted:

* `host` -  IP or name for the vSphere API
* `insecure` - _Optional_ verify SSL certificate from the host
* `user' - user name for connecting to vSphere
* `password` - password  for connecting to vSphere
* `data_center_name` - _Optional_ datacenter containing the computed resource, the template and where the new VM will be created, if not specified the first datacenter found will be used
* `compute_resource_name` - the name of the host containing the resource pool for the new VM
* `resource_pool_name` - the resource pool for the new VM
* `template_name` - the VM template to clone
* `name` - name of the new VM

## Version History
* 0.0.1
  * Initial release

## Versioning

This plugin follows the principles of [Semantic Versioning 2.0.0](http://semver.org/)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

GI-Cat Driver is licensed under the MIT license. See [LICENSE.txt][license].

[license]: https://raw.github.com/nsidc/vagrant-vsphere/master/LICENSE.txt

## Credit

This software was developed by the National Snow and Ice Data Center with funding from multiple sources.