# Continuous Integration, Delivery, and Deployment with Docker

Training session at [Velocity NY, 2016](http://conferences.oreilly.com/velocity/devops-web-performance-ny/public/schedule/detail/52480).

Times: 9:00am – 5:00pm
Days: Monday, September 19 - Tuesday September 20
Room: Clinton

## Requirements

### Hardware

- Laptop

### Software

**Linux**

- Bash Shell
- Git: <https://git-scm.com/download/linux>
- Docker: <https://docs.docker.com/engine/installation/>

**Mac OS**

- Bash Terminal
- Homebrew: <http://brew.sh/>
- Git: `$ brew install git`
- VirtualBox: https://www.virtualbox.org/wiki/Downloads
- Docker Toolbox: <https://www.docker.com/products/docker-toolbox>

**Windows**

- GitBash: <https://github.com/git-for-windows/git/releases/latest/>
- VirtualBox: https://www.virtualbox.org/wiki/Downloads
- Docker Toolbox: <https://www.docker.com/products/docker-toolbox>

### SaaS

- DC/OS Community Slack Account: <http://chat.dcos.io/>
- GitHub Account: <https://github.com/>
- Docker Hub Account: <https://hub.docker.com/>

### Platform

- [DC/OS](https://dcos.io/) cluster (provided)

## Setup

1. Launch Bash Shell

1. Clone the Training Repo

    ```
    $ mkdir ~/workspace
    $ cd ~/workspace
    $ git clone https://github.com/mesosphere/training.git
    $ cd training
    ```

    For the rest fo the training, the training directory will be referred to as `$DCOS_HOME`.

1. (Mac & Windows) Configure docker-machine VM

    Create VM

    ```
    $ docker-machine create \
      --driver=virtualbox \
      --engine-storage-driver=overlay \
      --virtualbox-cpu-count=4 \
      --virtualbox-disk-size=102400 \
      --virtualbox-memory=6144 \
      dockerd
    ```


    Route Docker IPs to VM

    **Mac**

    ```
    $ sudo route -nv add -net 172.17.0.0/16 192.168.65.50
    ```

    To undo: `sudo route delete 172.17.0.0/16`

    **Windows**

    ```
    $ route add 172.17.0.0 mask 255.255.0.0 192.168.65.50 -p
    ```

## Agenda

**Day 1**

1. [Docker 101 - Containers & Images](docker101/)
1. Docker 102 - Best Practices
1. [DC/OS 101 - ?](dcos/)

**Day 2**

1. Jenkins Intro
1. Artifactory Intro (maybe)
1. GitLab Intro (maybe)
1. Jenkins Pipeline Example
1. Deployment Strategies
1. CI Best Practices
1. Microservice Best Practices


## External Resources

- [DC/OS docs](https://dcos.io/docs/1.8/)
- [Marathon docs](https://mesosphere.github.io/marathon/docs/)
- [Mesos docs](http://mesos.apache.org/documentation/latest/)
- [DC/OS service discovery cheat sheet](https://github.com/dcos-labs/dcos-sd)
- [Marathon app spec validation](https://github.com/dcos-labs/marathon-validate)
- [Valuable Docker Links](http://www.nkode.io/2014/08/24/valuable-docker-links.html)
