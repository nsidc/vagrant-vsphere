#!/bin/bash

if [ -n "$(vagrant plugin list |grep vagrant-vsphere)" ]; then
    vagrant plugin uninstall vagrant-vsphere
fi
rm -f *.gem
gem build vSphere.gemspec
vagrant plugin install vagrant-vsphere --plugin-source ./vagrant-vsphere-1.11.0.gem
