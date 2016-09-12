# Continuous Integration, Delivery, and Deployment with Docker

Training session at [Velocity NY, 2016](http://conferences.oreilly.com/velocity/devops-web-performance-ny/public/schedule/detail/52480).

- **Date**: Monday, September 19 - Tuesday, September 20
- **Time**: 9:00am – 5:00pm
- **Venue**: Clinton Room, Hilton NY

## Requirements

### Hardware

- Laptop

### Software

**Linux**

- Bash Shell (built in)
- Git: <https://git-scm.com/download/linux>
- Docker: <https://docs.docker.com/engine/installation/>

**Mac OS**

- Bash Terminal (built in)
- Git: [Homebrew](http://brew.sh/) + `brew install git`
- Docker: [Mac Install Options](https://github.com/mesosphere/training/blob/master/velocity-training-09-2016/docker-install-mac.md)

**Windows**

- GitBash: <https://github.com/git-for-windows/git/releases/latest/>
- Docker: [Windows Install Options](https://github.com/mesosphere/training/blob/master/velocity-training-09-2016/docker-install-windows.md)

### SaaS

- DC/OS Community Slack Account: <http://chat.dcos.io/>
- GitHub Account: <https://github.com/>
- Docker Hub Account: <https://hub.docker.com/>

### Container Platform

- [DC/OS](https://dcos.io/) cluster (provided)

## Setup

1. Launch Bash Shell (or SSH into the Linux VM)

1. Clone the Training Repo

    ```
    $ mkdir ~/workspace
    $ cd ~/workspace
    $ git clone https://github.com/mesosphere/training
    $ cd training
    ```

    For the rest of the training, the training directory will be referred to as `$DCOS_HOME`.

## Agenda

**Day 1**

1. [Docker 101 - Containers & Images](docker-101.md)
1. Docker 102 - Best Practices
1. [DC/OS 101 - ?](dcos-101.md)

**Day 2**

1. Jenkins Intro
1. Artifactory Intro (maybe)
1. GitLab Intro (maybe)
1. Jenkins Pipeline Example
1. Deployment Strategies
1. CI Best Practices
1. Microservice Best Practices

**Daily Break Schedule**

| Time | Location |
|------|----------|
| 10:30 - 11:00am | Sutton Complex Foyer (right outside training rooms) |
| 12:30 - 1:30pm | Rhinelander (same floor as training) |
| 3:00 - 3:30pm | Sutton Complex Foyer |


## External Resources

- [DC/OS docs](https://dcos.io/docs/1.8/)
- [Marathon docs](https://mesosphere.github.io/marathon/docs/)
- [Mesos docs](http://mesos.apache.org/documentation/latest/)
- [DC/OS service discovery cheat sheet](https://github.com/dcos-labs/dcos-sd)
- [Marathon app spec validation](https://github.com/dcos-labs/marathon-validate)
- [Valuable Docker Links](http://www.nkode.io/2014/08/24/valuable-docker-links.html)
