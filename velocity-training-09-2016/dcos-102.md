# DC/OS 102 - CLI

The DC/OS CLI is the primary programmatic control interface for observing and managing your cluster.

## Agenda

- [Install](#install)
- [Log In](#log-in)
- [Create Service](#create-service)
- [View Service List](#view-service-list)
- [Locate Service Endpoint](#locate-service-endpoint)
- [Destroy Service](#destroy-service)

## Install

Follow the platform-specific instructions in the UI for installing and configuring the CLI.

![Install CLI](images/dcos-cli-install.png)

Use the Linux instructions if you're using a Linux VM for your workspace.

TODO: do the Windows instructions work in GitBash?

## Log in

```
$ dcos auth login
```

Follow instructions to generate an OAuth token in a browser and paste it into the CLI.

## Create Service

Install MinitTwit as a new Service.

```
# create service definition
$ cat > minitwit.json << EOF
{
  "id": "/minitwit",
  "instances": 1,
  "cpus": 1,
  "mem": 256,
  "container": {
    "docker": {
      "image": "karlkfi/minitwit",
      "forcePullImage": false,
      "privileged": false,
      "portMappings": [
        {
          "hostPort": 80,
          "containerPort": 80,
          "protocol": "tcp"
        }
      ],
      "network": "BRIDGE"
    }
  },
  "acceptedResourceRoles": [
    "slave_public"
  ],
  "requirePorts": true
}
EOF

# create service
dcos marathon app add < minitwit.json
```

## View Service List

```
$ dcos marathon app list
```

## Locate Service Endpoint

Because this service is mapping to port 80 on the host, we can use the host's IP.

```
$ dcos marathon app show minitwit | jq -r .tasks[0].host
```

## Destroy Service

```
# stop the service (could be started again later)
$ dcos marathon app stop minitwit

# remove the service (delete record and logs)
$ dcos marathon app remove minitwit
```

## Next Up

[DC/OS 103 - Health Checks & SSH](dcos-103.md)
