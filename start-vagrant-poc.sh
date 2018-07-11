#!/bin/bash
cd vx-simulation
vagrant up oob-mgmt-server oob-mgmt-switch
sleep 10
vagrant up
