# Mesos and Marathon 101

Keep https://mesosphere.github.io/marathon/docs/ open in a browser, you'll need it.


## Install Marathon

Since Marathon is installed by default on DCOS this is a NOP.

## Launch apps via the Marathon UI 

- Got to DCOS dashboard and click on the Marathon service
- In the Marathon UI
 - Start simple app such as `while [ true ] ; do echo "Hello DCOS" ; sleep 5 ; done`
 - Scale up and down
 - Make yourself familiar with health checks

![Marathon Ui](../img/marathon-ui.png)

## Launch apps via Marathon HTTP API

Note that we will use [HTTPie](http://httpie.org) in the following but you can use `curl` should you wish to do that.

    $ cd $DCOS_CLI_HOME
    $ http POST http://$DCOS_DASHBOARD_FQHN/service/marathon/v2/apps < velocity-training/mesos-marathon/marathon-hello-world.json

There are two more sample app specs here in this directory: `marathon-peek.json` that launches a Docker images and `marathon-private-registry.json` that launches a Docker registry. 

## List apps via Marathon HTTP API

    $ http http://$DCOS_DASHBOARD_FQHN/service/marathon/v2/apps | python -mjson.tool

## Use Marathon in DCOS

    $ cd $DCOS_CLI_HOME
    $ dcos marathon app add velocity-training/mesos-marathon/marathon-private-registry.json
    $ dcos marathon app list
