#!/bin/bash
cd vx-libvirt-simulation
vagrant up oob-mgmt-server oob-mgmt-switch
sleep 10
vagrant up
