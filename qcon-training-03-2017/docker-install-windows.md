# Install Docker on Windows

The Windows kernel does not support native containers. So a virtual machine is required to run the Docker engine.

The following options are available:

- **(Recommended)** "Docker for Windows"

    Requires Microsoft Hyper-V, which comes with Windows 10 Pro and above (not Home).

- Docker Toolbox with VirtualBox

    Docker Toolbox on Windows is a bit buggy. It may work for you, or it may not.

- Docker in a VirtualBox Linux VM

    If the above don't work, the last option is to launch a Linux VM, SSH into it, and use Docker exclusively inside a Linux environment.

    For this, I recommend using [dcos-vagrant-box](https://github.com/dcos/dcos-vagrant-box), which has all of the necessary tools pre-installed.

## Docker for Windows

1. Install Docker for Windows

    If Hyper-V is not already enabled, the installer will ask you to Enable & Restart.

1. Route Docker IPs to VM

    Open PowerShell as administrator and run the following commands:

    ```
    # Get the IP of the Docker VM
    $ $DOCKER_MACHINE_IP = (Get-VMNetworkAdapter -VMName MobyLinuxVM).IPAddresses[0]

    # Create the route
    $ route add 172.17.0.0 mask 255.255.0.0 $DOCKER_MACHINE_IP -p
    ```

    To undo, later: `route delete 172.17.0.0`

1. Verify Installation

    ```
    $ docker version
    Client:
     Version:      1.12.0
     API version:  1.24
     Go version:   go1.6.3
     Git commit:   8eab29e
     Built:        Thu Jul 28 21:15:28 2016
     OS/Arch:      windows/amd64

    Server:
     Version:      1.12.0
     API version:  1.24
     Go version:   go1.6.3
     Git commit:   8eab29e
     Built:        Thu Jul 28 21:15:28 2016
     OS/Arch:      linux/amd64
    ```

## Docker in a VirtualBox Linux VM

1. Install VirtualBox and Vagrant

    - VirtualBox 5.0.26: <http://download.virtualbox.org/virtualbox/5.0.26/VirtualBox-5.0.26-108824-Win.exe>
    - Vagrant 1.8.4: <https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4.msi>

    These versions are known to work. Unfortunately, VirtualBox 5.1 requires Vagrant 1.8.5 and Vagrant 1.8.5 is buggy.

1. Clone the dcos-vagrant-box Repo

    ```
    git clone https://github.com/dcos/dcos-vagrant-box
    cd dcos-vagrant-box
    ```

1. Create the VM

    ```
    vagrant up
    ```

1. Route Docker IPs to VM

    ```
    # find the IP of the VM
    $ DOCKER_IP=$(vagrant ssh -c 'hostname -I' | cut -d' ' -f1)

    # create the route
    $ sudo route -nv add -net 172.17.0.0/16 $DOCKER_IP
    ```

    To undo, later: `sudo route delete 172.17.0.0/16`

1. SSH into the VM

    ```
    vagrant ssh
    ```

1. Verify Installation

    ```
    $ docker version
    Client:
     Version:      1.11.2
     API version:  1.23
     Go version:   go1.5.4
     Git commit:   b9f10c9
     Built:        Wed Jun  1 21:23:11 2016
     OS/Arch:      linux/amd64

    Server:
     Version:      1.11.2
     API version:  1.23
     Go version:   go1.5.4
     Git commit:   b9f10c9
     Built:        Wed Jun  1 21:23:11 2016
     OS/Arch:      linux/amd64
    ```

    Note that this has Docker 1.11 instead of 1.12. Upgrading to 1.12 will likely break on CentOS. So don't bother. We wont be using 1.12 features.

1. Install Git

    ```
    sudo yum install git -y
    ```
