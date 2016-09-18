# Jenkins 101 - Quickstart

## Agenda
TODO: Agenda

- Install Jenkins Package
- Create Jenkins Project

## Install Jenkins Package

Jenkins is available to install from the Mesosphere Universe DC/OS package repository.

This version of Jenkins is configured specifically to act as a DC/OS scheduler. It can create Jenkins agents on demand, running in docker containers. This makes new agent provisioning MUCH faster than the standard methods of manual bare-metal provisioning or automatic virtual machine provisioning.

Like all Universe packages, Jenkins may be installed with either the DC/OS GUI or CLI.

By default, the Jenkins package uses a temporary storage directory, meaning no state will be saved if it crashes, is upgraded, or its machine dies.

To ensure that state is recoverable on process termination & resurrection (but not node loss), set `storage.host-volume` to mount a host volume and `storage.pinned-hostname` to constrain the service to a single node IP hostname (or IP).

If sharing a DC/OS cluster, make sure to use unique `name` and `host-volume` values to avoid collision with other Jenkins installations.

To install Jenkins with the DC/OS CLI:

```
# select a node hostname to pin too
$ NODE_HOSTNAME="$(dcos node --json | jq -r .[].hostname | tail -1)"

# create package config file
$ cat > pkg-jenkins.json << EOF
{
  "service": {
    "name": "jenkins"
  },
  "storage": {
    "host-volume": "/mnt/jenkins_data"
    "pinned-hostname": "${NODE_HOSTNAME}"
  }
}
EOF

# install package
$ dcos package install jenkins --options=pkg-jenkins.json
```

Once installed, running, and ready, the Jenkins GUI may be reached through the admin router at `http://${DCOS_ADDRESS}/service/jenkins/`.

![Jenkins Dashboard](images/jenkins-fresh-install.png)

## Create Jenkins Project

Jenkins has many different types of projects for different kinds of builds and pipelines.

The simplest type is a "freestyle" project.
Freestyle project most often use custom shell scripts to execute standalone builds.
However, in most use cases there are several stages necessary to full tests a project.

One of the most common uses for freestyle projects is to perform tests on code that has been committed to a source repository (SCM). This is the most basic type of continuous integration.

TODO: setup a freestyle build that runs unit tests

TODO: configure builds for master and PR branches
