# Mesos, Marathon and DCOS basics

Architecture, system components and services.

## Using Marathon in DCOS

Keep https://mesosphere.github.io/marathon/docs/ open in a browser, you'll need it.

### Launching apps via the  UI 

- Got to DCOS dashboard and click on the Marathon service
- In the Marathon UI
 - Start simple app such as `while [ true ] ; do echo "Hello DCOS" ; sleep 5 ; done`
 - Scale up and down
 - Make yourself familiar with health checks

### Launching apps via the CLI

    $ cd $DCOS_HOME
    $ dcos marathon app add dcos-bootcamp-04-2016/dcos/marathon-peek.json
    $ dcos marathon app list
    $ dcos task

