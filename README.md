## begin-ansible-training-ospf-nclu

### Summary:

This is an Ansible demo which configures two Cumulus VX switches with OSPF using Ansible's NCLU module

### Network Diagram:

![Network Diagram](https://github.com/chronot1995/begin-ansible-training-ospf-nclu/blob/master/documentation/begin-ansible-training-ospf-nclu.png)

### Initializing the demo environment:

First, make sure that the following is currently running on your machine:

1. Vagrant > version 2.1.2

    https://www.vagrantup.com/

2. Virtualbox > version 5.2.16

    https://www.virtualbox.org

3. Copy the Git repo to your local machine:

    ```git clone https://github.com/chronot1995/begin-ansible-training-ospf-nclu```

4. Change directories to the following

    ```begin-ansible-training-ospf-nclu```

6. Run the following:

    ```./start-vagrant-poc.sh```

### Running the Ansible Playbook

1. SSH into the oob-mgmt-server:

    ```vagrant ssh oob-mgmt-server```

2. Copy the Git repo unto the oob-mgmt-server:

    ```git clone https://github.com/chronot1995/begin-ansible-training-ospf-nclu```

3. Change directories to the following

    ```begin-ansible-training-ospf-nclu/automation```

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

    ```python2 topology_converter.py begin-ansible-training-ospf-nclu.dot -c```

    After the above command is executed, the following configuration changes are necessary:

4. Within ```vx-simulation/helper_scripts/auto_mgmt_network/OOB_Server_Config_auto_mgmt.sh```

The following stanza:

    #Install Automation Tools
    puppet=0
    ansible=1
    ansible_version=2.3.1.0

Will be replaced with the following:

    #Install Automation Tools
    puppet=0
    ansible=1
    ansible_version=2.6.2

The following stanza will replace the install_ansible function:

```
install_ansible(){
echo " ### Installing Ansible... ###"
apt-get install -qy ansible sshpass libssh-dev python-dev libssl-dev libffi-dev
sudo pip install pip --upgrade
sudo pip install setuptools --upgrade
sudo pip install ansible==$ansible_version --upgrade
}```

Add the following ```echo``` right before the end of the file.

    echo " ### Adding .bash_profile to auto login as cumulus user"
    echo "sudo su - cumulus" >> /home/vagrant/.bash_profile
    echo "exit" >> /home/vagrant/.bash_profile

    echo "############################################"
    echo "      DONE!"
    echo "############################################"
