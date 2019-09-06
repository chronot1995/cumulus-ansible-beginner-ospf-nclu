## cumulus-ansible-beginner-ospf-nclu

### Summary:

  - Cumulus Linux 3.7.8
  - Underlying Topology Converter to 4.7.0
  - Tested against Vagrant 2.1.5 on Mac and Linux. Windows is not supported.
  - Tested against Virtualbox 5.2.32 on Mac 10.14
  - Tested against Libvirt 1.3.1 and Ubuntu 16.04 LTS

### Description:

This is an Ansible demo which configures two Cumulus VX switches with OSPF using Ansible's NCLU module

### Network Diagram:

![Network Diagram](https://github.com/chronot1995/cumulus-ansible-beginner-ospf-nclu/blob/master/documentation/cumulus-ansible-beginner-ospf-nclu.png)

### Install and Setup Virtualbox on Mac

Setup Vagrant for the first time on Mojave, MacOS 10.14.6

1. Install Homebrew 2.1.9 (This will also install Xcode Command Line Tools)

    https://brew.sh

2. Install Virtualbox (Tested with 5.2.32)

    https://www.virtualbox.org

I had to go through the install process twice to load the proper security extensions (System Preferences > Security & Privacy > General Tab > "Allow" on bottom)

3. Install Vagrant (Tested with 2.1.5)

    https://www.vagrantup.com

### Install and Setup Linux / libvirt demo environment:

First, make sure that the following is currently running on your machine:

1. This demo was tested on a Ubuntu 16.04 VM w/ 4 processors and 32Gb of Diagram

2. Following the instructions at the following link:

    https://docs.cumulusnetworks.com/cumulus-vx/Development-Environments/Vagrant-and-Libvirt-with-KVM-or-QEMU/

3. Download the latest Vagrant, 2.1.5, from the following location:

    https://www.vagrantup.com/

### Initializing the demo environment:

1. Copy the Git repo to your local machine:

    ```git clone https://github.com/chronot1995/cumulus-ansible-beginner-ospf-nclu```

2. Change directories to the following

    ```cumulus-ansible-beginner-ospf-nclu```

3a. Run the following for Virtualbox:

    ```./start-vagrant-vbox-poc.sh```

3b. Run the following for Libvirt:

    ```./start-vagrant-libvirt-poc.sh```

### Running the Ansible Playbook

1a. SSH into the Virtualbox oob-mgmt-server:

    ```cd vx-vbox-simulation```   
    ```vagrant ssh oob-mgmt-server```

1a. SSH into the Libvirt oob-mgmt-server:

    ```cd vx-libvirt-simulation```   
    ```vagrant ssh oob-mgmt-server```

2. Copy the Git repo unto the oob-mgmt-server:

    ```git clone https://github.com/chronot1995/cumulus-ansible-beginner-ospf-nclu```

3. Change directories to the following

    ```cumulus-ansible-beginner-ospf-nclu/automation```

4. Run the following:

    ```./provision.sh```

This will bring run the automation script and configure the two switches with OSPF.

### Troubleshooting

Helpful NCLU troubleshooting commands:

- net show route
- net show ospf neighbor
- net show interface | grep -i UP
- net show lldp

Helpful Linux troubleshooting commands:

- ip route
- ip link show
- ip address <interface>

The OSPF neighbor command will show if each switch had formed an adjacency:

```
cumulus@switch01:mgmt-vrf:~$ net show ospf neighbor

Neighbor ID     Pri State           Dead Time Address         Interface            RXmtL RqstL DBsmL
10.2.2.2          1 Full/DROther      36.952s 10.2.2.2        swp1:10.1.1.1            0     0     0
10.2.2.2          1 Full/DROther      39.293s 10.2.2.2        swp2:10.1.1.1            0     0     0

```

One should see that the corresponding loopback route is installed with two next hops / ECMP:

```
cumulus@switch01:mgmt-vrf:~$ net show route

show ip route
=============
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - , P - PIM, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel,
       > - selected route, * - FIB route

K>* 0.0.0.0/0 [0/0] via 10.0.2.2, vagrant, 00:00:20
C>* 10.0.2.0/24 is directly connected, vagrant, 00:00:20
C * 10.1.1.1/32 is directly connected, swp2, 00:00:14
C * 10.1.1.1/32 is directly connected, swp1, 00:00:16
O   10.1.1.1/32 [110/0] is directly connected, lo, 00:00:19
C>* 10.1.1.1/32 is directly connected, lo, 00:00:20
O>* 10.2.2.2/32 [110/100] via 10.2.2.2, swp1 onlink, 00:00:04
  *                       via 10.2.2.2, swp2 onlink, 00:00:04

```

### Errata

1. To shutdown the demo, run the following command from the vx-simulation directory:

    ```vagrant destroy -f```

2. This topology was configured using the Cumulus Topology Converter found at the following URL:

    https://github.com/CumulusNetworks/topology_converter

3. The following command was used to run the Topology Converter within the vx-simulation directory:

    ```./topology_converter.py cumulus-ansible-beginner-bgp-j2.dot -c```

After the above command is executed, the following configuration changes are necessary:

4. Within ```vx-simulation/helper_scripts/auto_mgmt_network/OOB_Server_Config_auto_mgmt.sh```

The following stanza:

echo " ### Creating cumulus user ###"
useradd -m cumulus

Will be replaced with the following:

echo " ### Creating cumulus user ###"
useradd -m cumulus -m -s /bin/bash

The following stanza:

    #Install Automation Tools
    puppet=0
    ansible=1
    ansible_version=2.6.3

Will be replaced with the following:

    #Install Automation Tools
    puppet=0
    ansible=1
    ansible_version=2.8.4

Add the following ```echo``` right before the end of the file.

    echo " ### Adding .bash_profile to auto login as cumulus user"
    echo "sudo su - cumulus" >> /home/vagrant/.bash_profile
    echo "exit" >> /home/vagrant/.bash_profile
    echo "### Adding .ssh_config to avoid HostKeyChecking"
    printf "Host * \n\t StrictHostKeyChecking no\n" >> /home/cumulus/.ssh/config

    echo "############################################"
    echo "      DONE!"
    echo "############################################"
