# netapp-kubernetes-ansible-demo
Demo for setting up a Kubernetes cluster with Kubespray and Ansible based on VMware and NetApp ONTAP with the Trident integration.

This setup is primarly a technology demonstration and can be used as an example. It is not intended to a be a production ready set of scripts. However if you want to reproduce it here are some tips that might help you.

# Architecture
The demo is based on a ansible control VM from which everything is deployed and controlled. In my scenario this VM is a clone of an Ubuntu based VMware template that I created as first step (see details below).

From that control VM the scripts will do the following
1. Create clones of a pre-existing VM template for a kubespray VM and the kubernetes cluster
2. Change a few items/install stuff in the cloned VMs
3. Setup a Kubernetes cluster with Kubespray on the cloned VMs
4. Create a new SVM with NFS and iSCSI on an a pre-existing ONTAP cluster
5. Install trident, backends and storage classes

# Preparation and Assumptions
The control VM needs Internet access to download and install packages/containers. During the setup the other VMs need Internet access as well. In my case I added a static Internet Gateway to all VMs (check script add-route-internet-gateway.yaml)

Tested and build with:
- vSphere 6.7
- ONTAP 9.5
- Trident 19.01
- Ubuntu 18.04 LTS
- Docker 18.06 & 18.09
- Ansible 2.7.5

I have a VMware Template called "ubuntu-devops-template" on a VMware NFS datastore that is the baseline for everything. The scripts should work with any other datastore as well but with NFS the beauty is that the clones do not take up any space and are instantly available with an ONTAP storage system. Most likely the scripts will fail on other Linux distros.

The template is based on Ubuntu 18.04 LTS and has a few items configured upfront:

- User & Access
  - Everything is based on the user name "netapp" and a public key is stored on the template (~netapp/.ssh/authorized_keys). On the controll VM there must be the private key under /home/netapp/.ssh/id_rsa
  - Add NOPASSWD to sudoers to allow SUDO access for ansible
  -  Example: https://code-maven.com/enable-ansible-passwordless-sudo
- Network is based on DHCP
  - Example for Ubuntu 18.04: https://www.serverlab.ca/tutorials/linux/administration-linux/how-to-configure-network-settings-in-ubuntu-18-04-bionic-beaver/
- NFS & rpcbind
  - sudo apt-get install -y nfs-common
  - sudo systemctl enable rpcbind
  - sudo systemctl start rpcbind
- Use apt via https
  - sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
- Add the GPG key for the official Docker repository to your system
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
- Add the Docker repo for Ubuntu & Install Docker
  - sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
  - sudo apt-cache policy docker-ce
  - sudo apt install docker-ce -y
- Set timezone
  - sudo timedatectl set-timezone Europe/Berlin
- Install pip (Python packet management tool)
  - sudo apt install python3-pip -y

On my ansible control VM I installed additionally some items:
- Ansible 
- VMware Python Ansible lib
  - pip install pyvmomi
- NetApp Ansible lib
  - pip install netapp-lib

