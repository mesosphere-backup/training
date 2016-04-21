# DC/OS bootcamp

Training session at Mesosphere HQ on 2016-04-14.

If you're not yet, please sign up and log into the DCOS Community Slack: [chat.dcos.io](http://chat.dcos.io/).

First you want to install the DC/OS CLI, authenticate against the cluster. Then, clone this repo in the directory where you've installed the CLI. For example, I've installed the CLI into `~/sandbox/dcos/ccm/dcos` hence I would do the following:

    $ pwd
    /Users/mhausenblas/sandbox/dcos/ccm/dcos
    $ git clone https://github.com/mesosphere/training.git

Going forward, we will call the directory you've installed the DC/OS CLI in simply `$DCOS_HOME`.

Lastly, check if you can access the DC/OS Dashboard and you're all set.

Sessions:

1. [Containers &amp; Docker](docker/)
1. [Mesos, Marathon and DC/OS basics](dcos/)
1. [CI/CD](ci-cd/)
1. [Big Data](big-data/)
