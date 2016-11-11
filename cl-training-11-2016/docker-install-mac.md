# Install Docker on Mac

The Mac kernel does not support native containers. So a virtual machine is required to run the Docker engine.

The following options are available:

- "Docker for Mac"

    <https://docs.docker.com/engine/installation/mac/>

    Docker for Mac has a critical flaw that you can't access the container IPs from the host. The other options are more useful.

- **(Recommended)** Docker Toolbox with VirtualBox

    Docker Toolbox works great and is well tested. Just make sure to create a docker-machine large enough for your needs.

- Docker in a VirtualBox Linux VM

    If the above don't work, the last option is to launch a Linux VM, SSH into it, and use Docker exclusively inside a Linux environment.

    For this, I recommend using [dcos-vagrant-box](https://github.com/dcos/dcos-vagrant-box), which has all of the necessary tools pre-installed.


## Docker Toolbox with VirtualBox

1. Install Docker Toolbox for Mac: <https://www.docker.com/products/docker-toolbox>

1. Create docker-machine VM

    ```
    $ docker-machine create \
      --driver=virtualbox \
      --engine-storage-driver=overlay \
      --virtualbox-cpu-count=4 \
      --virtualbox-disk-size=102400 \
      --virtualbox-memory=6144 \
      dockerd
    ```

1. Route Docker IPs to VM

    ```
    $ sudo route -nv add -net 172.17.0.0/16 $(docker-machine ip dockerd)
    ```

    To undo, later: `sudo route delete 172.17.0.0/16`

1. Configure the shell environment

    ```
    eval $(docker-machine env dockerd)
    ```

    This will need to be done every time you launch a new shell.

1. Verify Installation

    ```
    $ docker version
    Client:
     Version:      1.12.0
     API version:  1.24
     Go version:   go1.6.3
     Git commit:   8eab29e
     Built:        Thu Jul 28 23:54:00 2016
     OS/Arch:      darwin/amd64

    Server:
     Version:      1.12.1
     API version:  1.24
     Go version:   go1.6.3
     Git commit:   23cf638
     Built:        Thu Aug 18 17:52:38 2016
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
