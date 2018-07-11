#!/bin/bash
ansible-playbook deploy.yaml -l servers,aruba-switches,spines,leaves,routers,exits

## git clone https://github.com/chronot1995/byu-poc
