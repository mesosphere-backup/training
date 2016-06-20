# Building and operating containerized applications at scale

Training session at [Velocity SC, 2016](http://conferences.oreilly.com/velocity/devops-web-performance-ca/public/schedule/detail/50529).

Please sign up and log into the DCOS Community Slack: [chat.dcos.io](http://chat.dcos.io/).

## Hands-on

First you want to get access to the cluster, [install the DC/OS CLI](https://dcos.io/docs/1.7/usage/cli/install/) and authenticate against the cluster. Then, clone this repo in the directory where you've installed the CLI:

    $ git clone https://github.com/mesosphere/training.git

Going forward, we will call the directory you've installed the DC/OS CLI in simply `$DCOS_HOME`.

Sessions:

1. [Container 101](container101/)
1. [Container operations](containerops/)
1. [CI/CD](ci-cd/)

## Resources

- [DC/OS docs](https://dcos.io/docs/1.7/)
- [Marathon doc](https://mesosphere.github.io/marathon/docs/)
- [Mesos doc](http://mesos.apache.org/documentation/latest/)
- [DC/OS service discovery cheat sheet](https://github.com/dcos-labs/dcos-sd)
- [Marathon app spec validation](https://github.com/dcos-labs/marathon-validate)