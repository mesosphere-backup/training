# Setup

## Software

**Linux**

- Bash Shell (built in)
- Git: <https://git-scm.com/download/linux>
- Docker: <https://docs.docker.com/engine/installation/>

**Mac OS**

- Bash Terminal (built in)
- Git: [Homebrew](http://brew.sh/) + `brew install git`
- Docker: [Mac Install Options](docker-install-mac.md)

**Windows**

- GitBash: <https://github.com/git-for-windows/git/releases/latest/>
- Docker: [Windows Install Options](docker-install-windows.md)

## SaaS

- DC/OS Community Slack Account: <http://chat.dcos.io/> `#qcon-2017` channel
- GitHub Account: <https://github.com/>
- Docker Hub Account: <https://hub.docker.com/>

## Container Platform

- [DC/OS](https://dcos.io/) cluster (will be provided)

## Training Repo

1. Launch Bash Shell (or SSH into the Linux VM)

1. Clone the Training Repo

    ```
    $ mkdir -p ~/workspace
    $ cd ~/workspace
    $ git clone https://github.com/mesosphere/training
    $ cd training/qcon-training-03-2017/
    ```

For the rest of the training, the training directory will be referred to as `$TRAINING_HOME`.
