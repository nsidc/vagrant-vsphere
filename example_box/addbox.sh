#!/bin/bash

tar cvzf dummy.box ./metadata.json
vagrant box add ./dummy.box --name dummy

