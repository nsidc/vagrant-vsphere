#!/bin/bash

vagrant plugin uninstall vagrant-vsphere
rm -f *.gem
gem build vSphere.gemspec
vagrant plugin install vagrant-vsphere --plugin-source file://vagrant-vsphere-1.11.0.gem
