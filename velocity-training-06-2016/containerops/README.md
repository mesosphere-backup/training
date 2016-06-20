# Container operations

Keep https://mesosphere.github.io/marathon/docs/ open in a browser, you'll need it.

## Launching apps via the  UI 

Go to DC/OS dashboard and click on the Marathon service

In the Marathon UI:

- Create an app with ID `hw` such as `while [ true ] ; do echo "Hello world!" ; sleep 10 ; done`
- Scale it up and down
- Kill tasks
- Explore logs
- Update the app spec to `while [ true ] ; do echo "Hello DC/OS!" ; sleep 5 ; done` and discuss what happens

## Launching apps via the CLI

Simple app server:

    $ dcos marathon app add peek.json
    $ dcos marathon app list
    $ dcos task

Try the other ones:

- A web server: [nginx.json](nginx.json)
- A simple blog: [jekyll.json](jekyll.json)
- A Slack-like chat app: [mattermost.json](mattermost.json)

For the following you'll need to have [Marathon-lb](https://dcos.io/docs/1.7/usage/service-discovery/marathon-lb/) installed:

- A Wordpress blog `wordpress.json`

This one uses [VIPs](https://dcos.io/docs/1.7/usage/service-discovery/virtual-ip-addresses/) for service discovery: 

- An app server `vipwebserver.json`
