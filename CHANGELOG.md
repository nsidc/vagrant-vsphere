## [1.15.0 (2024-12-12)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.15.0)

 - Update gem to require Ruby 3.3.6
 - Support for vagrant 2.4.3
 - Update dependencies

## [1.14.0 (2022-08-01)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.14.0.pre1)

  - Update gem to ruby 3.0.2
  - Support for vagrant >=2.2.17
  - Update nokogiri dependency (1.13.4) to take care of dependabot alerts
  - Update rbvmomi, rake, rubocop dependencies

## [1.13.5 (2021-01-05)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.13.5)
  - Pin nokogiri to 1.10.10. This fixes an issue where vagrant-vsphere failed to install due to 
    nokogiri requiring Ruby >=2.5.  This is a workaround until the vagrant-nsidc plugin is updated
    to work with newer versions of vagrant that are bundled with newer versions of Ruby

## [1.13.4 (2020-03-31)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.13.4)

  - Allow newer versions of i18n.
    ([jmartin-r7:release-i18n](https://github.com/nsidc/vagrant-vsphere/pull/286))
  - Updated .ruby-version to 2.6.5
  - Fix broken tests.
    ([wwestenbrink:master](https://github.com/nsidc/vagrant-vsphere/pull/283))

## [1.13.3 (2018-12-06)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.13.3)

  - Update i18n dependency to allow v1.1.1. This fixes an issue with
    installation with Vagrant 2.2.x
    ([jarretlavallee:fix/master/il8n_deps](https://github.com/nsidc/vagrant-vsphere/pull/273)).

## [1.13.2 (2017-12-06)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.13.2)

  - Update rbvmomi dependency to v1.11.5 and greater (but still less than
    2.0). v1.11.5 fixes the issue introduced in v1.11.4.

## [1.13.1 (2017-12-05)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.13.1)

  - Update rbvmomi dependency to avoid v1.11.4; something in
    [2725089](https://github.com/vmware/rbvmomi/commit/2725089a08312315c4eb85f13296fc159f50b4d1)
    broke cloning VMs on NSIDC's vSphere instance.


## [1.13.0 (2017-11-06)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.13.0)

  - Add support for the commands
    [`suspend`](https://www.vagrantup.com/docs/cli/suspend.html) and
    [`resume`](https://www.vagrantup.com/docs/cli/resume.html).

## [1.12.1 (2017-03-07)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.12.1)

  - If no valid adapters can be found on a host when using the `real_nic_ip`
    option, fall back to the value of `vm.guest.ipAddress`. This resolves an
    issue where the network changes made by Docker Swarm prevent vagrant-vsphere
    from acquiring the VM's IP address.

## [1.12.0 (2017-03-07)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.12.0)

  - Make `wait_for_sysprep` functionality configurable (see README.md for
    details). Defaults to `false` to resolve
    #222. ([nsidc:make-sysprep-configurable](https://github.com/nsidc/vagrant-vsphere/pull/235))
  - Fix issue (#231) where finding no adapters while waiting for the IP address
    to be ready broke the `up`
    process. ([nsidc:fix-filter-ssh](https://github.com/nsidc/vagrant-vsphere/pull/234))
  - Fix installation of vagrant-vsphere under Vagrant
    1.9.2. ([nsidc:fix-install-with-1.9.2](https://github.com/nsidc/vagrant-vsphere/pull/233))

## [1.11.1 (2017-02-27)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.11.1)
  - Fix 'real_nic_ip' filter logic bug
    ([vagrant-vsphere:fix_ssh_ip_selection](https://github.com/nsidc/vagrant-vsphere/pull/229))

## [1.11.0 (2016-11-23)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.11.0)

  - Wait for Windows sysprep when cloning a Windows box
    ([jcaugust:sysprep_wait](https://github.com/nsidc/vagrant-vsphere/pull/199)).
  - Add a configurable timeout period for obtaining the VM's IP address
    ([taliesins:wait-for-ip](https://github.com/nsidc/vagrant-vsphere/pull/204)).

## [1.10.1 (2016-10-17)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.10.1)

  - Update dependency on [rbvmomi](https://github.com/vmware/rbvmomi) to allow
    versions greater than `1.8.2`, but still less than `2.0.0`. The previous
    version constraint was intended to get at least `1.8.2`, but was also
    restricting it to less than `1.9.0`.

## [1.10.0 (2016-05-17)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.10.0)

  - Add support for `vagrant snapshot` and its subcommands
    ([Sharpie:add-snapshot-support](https://github.com/nsidc/vagrant-vsphere/pull/198)).

## [1.9.0 (2016-05-17)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.9.0)

  - Add real_nic_ip option/logic to support VMs with multiple bridge adapters
    ([vagrant-vsphere:invalid_ip_address_fix](https://github.com/nsidc/vagrant-vsphere/pull/193)).

## [1.8.1 (2016-04-27)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.8.1)

  - Fix error for initial VLAN/virtual switch support
    ([adampointer:master](https://github.com/nsidc/vagrant-vsphere/pull/190)).


## [1.8.0 (2016-04-21)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.8.0)

  - Allow VLANs on virtual switches to work correctly
    ([adampointer:master](https://github.com/nsidc/vagrant-vsphere/pull/188)).
  - Make compatible with `i18n` v0.7.0 (resolving
    [#163](https://github.com/nsidc/vagrant-vsphere/pull/163)).
  - Add support for specifying a full resource pool name
    ([davidhrbac:master](https://github.com/nsidc/vagrant-vsphere/pull/152) and
    [#189](https://github.com/nsidc/vagrant-vsphere/pull/189)).

## [1.7.1 (2016-03-30)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.7.1)

  - Allow `vagrant status` and `vagrant ssh` to run without a lock
    ([Sharpie:dont-lock-for-ssh](https://github.com/nsidc/vagrant-vsphere/pull/184)).

## [1.7.0 (2016-03-14)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.7.0)

  - Add support for setting guestinfo variables
    ([Sharpie:add-guestinfo-support](https://github.com/nsidc/vagrant-vsphere/pull/174)).
  - Run provisioner cleanup when destroying VMs
    ([Sharpie:enable-provisioner-cleanup](https://github.com/nsidc/vagrant-vsphere/pull/176)).
  - Add the ability to configure the notes on the newly cloned VM
    ([rylarson:feature/rylarson-add-notes](https://github.com/nsidc/vagrant-vsphere/pull/178)).

## [1.6.0 (2016-01-21)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.6.0)

  - Use Vagrant core API instead of waiting for SSH communicator, which should
    resolve some WinRM connection issues
    ([mkuzmin:wait-winrm](https://github.com/nsidc/vagrant-vsphere/pull/162)).

## [1.5.0 (2015-09-08)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.5.0)

  - Add support for custom attributes
    ([michaeljb:custom-attributes](https://github.com/nsidc/vagrant-vsphere/pull/149)).

## [1.4.1 (2015-09-01)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.4.1)

  - Update dependency on [rbvmomi](https://github.com/vmware/rbvmomi) to 1.8.2
    in order to resolve errors with parallelization
    ([#139]((https://github.com/nsidc/vagrant-vsphere/issues/139)),
    [edmcman:master](https://github.com/nsidc/vagrant-vsphere/pull/147)).

## [1.4.0 (2015-07-29)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.4.0)

  - Add ability to configure the address type (originally submitted in
    [mreuvers:master](https://github.com/nsidc/vagrant-vsphere/pull/121), but
    merged
    [nsidc:address-type](https://github.com/nsidc/vagrant-vsphere/pull/142))

## [1.3.0 (2015-07-21)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.3.0)

  - Add ability to configure CPU and memory reservations
    ([edmcman:resource_limit](https://github.com/nsidc/vagrant-vsphere/pull/137))
  - Bypass "graceful" shut down attempts with `vagrant destroy --force`

## [1.2.0 (2015-07-09)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.2.0)

  - Add `public_address` provider capability
    ([mkuzmin:public-address](https://github.com/nsidc/vagrant-vsphere/pull/130))
  - Documentation update
    ([standaloneSA:update-readme](https://github.com/nsidc/vagrant-vsphere/pull/133))

## [1.1.0 (2015-07-09)](https://github.com/nsidc/vagrant-vsphere/releases/tag/v1.1.0)

  - Add explicit support for parallelization
    ([xlucas:xlucas-patch-parallelization](https://github.com/nsidc/vagrant-vsphere/pull/126))
  - Documentation updates
    ([metrix78:metrix78-patch-1](https://github.com/nsidc/vagrant-vsphere/pull/127)
    and
    [fabriciocolombo:readme-ipaddress](https://github.com/nsidc/vagrant-vsphere/pull/128))

## 1.0.1 (2015-01-06)

  - Fix "undefined local variable or method datastore" error due to typo in a
    variable name
    ([#116 mkuzmin:datastore](https://github.com/nsidc/vagrant-vsphere/pull/116))
  - Remove "missing required parameter uuid" error from `vagrant destroy` output
    when no machine exists
    ([#117 mkuzmin:destroy](https://github.com/nsidc/vagrant-vsphere/pull/117))

## 1.0.0 (2015-01-05)

  - Increase Vagrant requirement to 1.6.4+
  - Update copyright date in LICENSE.txt

## 0.19.1 (2014-12-31)

  - Move version history and contributing notes out of `README.md` into separate
    files
  - Add RuboCop, fail the Travis-CI build if RuboCop or unit tests fail

## 0.19.0 (2014-12-31)

  - Add support for ClusterComputeResource and DatastoreCluster
    ([#101 GregDomjan:StorageSDRS](https://github.com/nsidc/vagrant-vsphere/pull/101))

## 0.18.0 (2014-12-30)

  - Gracefully power off the VM with `vagrant halt`, and shutdown before
    deleting the VM with `vagrant destroy`
    ([#104 clintoncwolfe:shutdown-guest-on-halt](https://github.com/nsidc/vagrant-vsphere/pull/104))
  - Add configuration option `mac` to specify a MAC address for the VM
    ([#108 dataplayer:master](https://github.com/nsidc/vagrant-vsphere/pull/108))

## 0.17.0 (2014-12-29)

  - Add ability to configure the CPU Count
    ([#96 rylarson:add-cpu-configuration](https://github.com/nsidc/vagrant-vsphere/pull/96))
  - Prompt the user to enter a password if none is given, or the configuration
    value is set to `:ask`
    ([#97 topmedia:password-prompt](https://github.com/nsidc/vagrant-vsphere/pull/97))
  - Add support for `vagrant reload`
    ([#105 clintoncwolfe:add-reload-action](https://github.com/nsidc/vagrant-vsphere/pull/105))
  - Fix compatibility with Vagrant 1.7 to use vSphere connection info from a
    base box
    ([#111 mkuzmin:get-state](https://github.com/nsidc/vagrant-vsphere/pull/111))

## 0.16.0 (2014-10-01)

  - Add ability to configure amount of memory the new cloned VM will have
    ([#94 rylarson:add-memory-configuration](https://github.com/nsidc/vagrant-vsphere/pull/94))

## 0.15.0 (2014-09-23)

  - Make `vagrant destroy` work in all vm states
    ([#93 rylarson:make-destroy-work-in-all-vm-states](https://github.com/nsidc/vagrant-vsphere/pull/93),
    fixes [#77](https://github.com/nsidc/vagrant-vsphere/issues/77))
    - If the VM is powered on, then it is powered off, and destroyed
    - If the VM is powered off, it is just destroyed
    - If the VM is suspended, it is powered on, then powered off, then
      destroyed

## 0.14.0 (2014-09-19)

  - Add vlan configuration
    ([#91 rylarson:add-vlan-configuration](https://github.com/nsidc/vagrant-vsphere/pull/91))
    - Added a new configuration option `vlan` that lets you specify the vlan
      string
    - If vlan is set, the clone spec is modified with an edit action to connect
      the first NIC on the VM to the configured VLAN

## 0.13.1 (2014-09-18)

  - Change Nokogiri major version dependency
    ([#90 highsineburgh:SAITRADLab-master](https://github.com/nsidc/vagrant-vsphere/pull/90))

## 0.13.0 (2014-09-03)

  - Find and install box file for multi-provider boxes automatically
    ([#86 mkuzmin:install-box](https://github.com/nsidc/vagrant-vsphere/pull/86)
    &
    [#87 mkuzmin/provider-name](https://github.com/nsidc/vagrant-vsphere/pull/87))

## 0.12.0 (2014-08-16)

  - Use a directory name where `Vagrantfile` is stored as a prefix for VM name
    ([#82 mkuzmin:name-prefix](https://github.com/nsidc/vagrant-vsphere/pull/82))

## 0.11.0 (2014-07-17)

  - Create the VM target folder if it doesn't exist
    ([#76 marnovdm:feature/create_vm_folder](https://github.com/nsidc/vagrant-vsphere/pull/76))

## 0.10.0 (2014-07-07)

  - New optional parameter to clone into custom folder in vSphere
    ([#73 mikola-spb:vm-base-path](https://github.com/nsidc/vagrant-vsphere/pull/73))
  - Follows [semver](http://semver.org/) better, this adds functionality in a
    backwards compatible way, so bumps the minor. 0.9.0, should have been a
    major version

## 0.9.2 (2014-07-07)

  - Instruct Vagrant to set the guest hostname according to `Vagrantfile`
    ([#69 ddub:set-hostname](https://github.com/nsidc/vagrant-vsphere/pull/69))

## 0.9.1 (2014-07-07)

  - Reuse folder sync code from Vagrant core
    ([#66 mkuzmin:sync-folders](https://github.com/nsidc/vagrant-vsphere/pull/66))

## 0.9.0 (2014-07-07)

  - Increases Vagrant requirements to 1.6.3+
  - Supports differentiating between SSH/WinRM communicator
    ([#67 marnovdm:feature/waiting-for-winrm](https://github.com/nsidc/vagrant-vsphere/pull/67))

## 0.8.5 (2014-07-07)

  - Fixed synced folders to work with WinRM communicator
    ([#72 10thmagnitude:master](https://github.com/nsidc/vagrant-vsphere/pull/72))

## 0.8.4 (2014-07-07)

  - Use root resource pool when cloning from template
    ([#63: matt-richardson:support-resource-pools-on-vsphere-standard-edition](https://github.com/nsidc/vagrant-vsphere/pull/63))

## 0.8.3 (2014-07-03)

  - Fixed "No error message" on rbvmomi method calls
    ([#74: mkuzmin:rbvmomi-error-messages](https://github.com/nsidc/vagrant-vsphere/pull/74))

## 0.8.2 (2014-04-23)

  - Fixes no error messages
    ([#58 leth:no-error-message](https://github.com/nsidc/vagrant-vsphere/pull/58))
  - Fixes typo ([#57 marnovdm](https://github.com/nsidc/vagrant-vsphere/pull/57))
  - Fixes additional no error messages

## 0.8.1 (2014-04-10)

  - Fixes [#47](https://github.com/nsidc/vagrant-vsphere/issues/47) via
    [#52 olegz-alertlogic](https://github.com/nsidc/vagrant-vsphere/pull/52)

## 0.8.0 (2014-04-08)

  - Adds configuration for connecting via proxy server
    ([#40 tkak:feature-proxy-connection](https://github.com/nsidc/vagrant-vsphere/pull/40))

## 0.7.2 (2014-04-08)

  - Includes template in get_location
    ([#38 tim95030:issue-27](https://github.com/nsidc/vagrant-vsphere/pull/38))
  - Updates `Gemfile` to fall back to old version of Vagrant if ruby < 2.0.0 is
    available

## 0.7.1 (2014-03-17)

  - Fixes rsync error reporting
  - Updates `locales/en.yaml`
  - Restricts RbVmomi dependency

## 0.7.0 (2013-12-31)

  - Handle multiple private key paths
  - Add auto name generation based on machine name
  - Add support for linked clones

## 0.6.0 (2013-11-21)

  - Add support for the `vagrant ssh -c` command

## 0.5.1 (2013-10-21)

  - Fix rsync on Windows, adapted from
    [mitchellh/vagrant-aws#77](https://github.com/mitchellh/vagrant-aws/pull/77)

## 0.5.0 (2013-10-17)

  - Allow setting static ip addresses using Vagrant private networks
  - Allow cloning from VM or template

## 0.4.0

  - Add support for specifying datastore location for new VMs

## 0.3.0

  - Lock Nokogiri version at 1.5.10 to prevent library conflicts
  - Add support for customization specs

## 0.2.0

  - Add halt action
    ([#16 catharsis:haltaction](https://github.com/nsidc/vagrant-vsphere/pull/16))

## 0.1.0

  - Add folder syncing with guest OS
  - Add provisioning

## 0.0.1

  - Initial release
