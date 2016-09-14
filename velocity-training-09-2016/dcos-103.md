# DC/OS 103 - Health Checks & Debugging

## Agenda

- [Health Checks](#health-checks)
- [Readiness Checks](#readiness-checks)
- [SSH Access](#ssh-access)
- [Component Logs](#component-logs)
- [Identify Marathon Leader](#identify-marathon-leader)

## Health Checks

When a service health check is configured, the service status will be healthy as soon as a health check passes.
If enough health checks fail (`maxConsecutiveFailures`), the status will change to unhealthy.

To add a health check, give the port mapping a name and create a `healthChecks` element that refers to it.

```
# updated service definition
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
          "protocol": "tcp",
          "name": "http-api"
        }
      ],
      "network": "BRIDGE"
    }
  },
  "acceptedResourceRoles": [
    "slave_public"
  ],
  "requirePorts": true,
  "healthChecks": [
    {
      "protocol": "TCP",
      "gracePeriodSeconds": 30,
      "intervalSeconds": 15,
      "timeoutSeconds": 5,
      "maxConsecutiveFailures": 2,
      "portName": "http-api"
    }
  ]
}
EOF

# create service
$ dcos marathon app add < minitwit.json

# check service health
$ dcos marathon app list
ID         MEM  CPUS  TASKS  HEALTH  DEPLOYMENT  CONTAINER  CMD
/minitwit  256   1     1/1    1/1       ---        DOCKER   None
```

![Service Healthy](images/dcos-service-healthy)

## Readiness Checks

When a service readiness check is configured, the service status will remain in the deploying stage until the readiness check is successful.
This is most useful when services take a long time to initialize. This way they wont be marked as unhealthy until after they are ready.

To add a readiness check, create a `readinessChecks` element that refers to a port by name.

```
# updated service definition
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
          "protocol": "tcp",
          "name": "http-api"
        }
      ],
      "network": "BRIDGE"
    }
  },
  "acceptedResourceRoles": [
    "slave_public"
  ],
  "requirePorts": true,
  "healthChecks": [
    {
      "protocol": "TCP",
      "gracePeriodSeconds": 30,
      "intervalSeconds": 15,
      "timeoutSeconds": 5,
      "maxConsecutiveFailures": 2,
      "portName": "http-api"
    }
  ],
  "readinessChecks": [
    {
      "protocol": "HTTP",
      "path": "/",
      "portName": "http-api",
      "intervalSeconds": 15,
      "timeoutSeconds": 5,
      "httpStatusCodesForReady": [ 200, 302 ],
      "preserveLastResponse": true
    }
  ]
}
EOF
```

![Service Deploying](images/dcos-service-deploying)

## SSH Access

If at any point you need to debug a DC/OS component, job, or service, you may need to SSH into the cluster.

In production, not all machines in a cluster should be internet accessible. So you may need to VPN into the cluster network and SSH into a bootstrap or master node as a jump box.

In the provided AWS clusters, the master nodes are internet accessible. So you can SSH into them and/or use them to proxy into agent nodes.

- Download SSH private key
- Generate SSH public key: `ssh-keygen -y -f ~/.ssh/dcoskey > ~/.ssh/dcoskey.pub`
- Set SSH private key permissions: `chmod 600 ~/.ssh/dcoskey`
- Add SSH private key to SSH client: `ssh-add ~/.ssh/dcoskey`
- SSH into remote machine: `ssh -A core@${MASTER_IP_ADDRESS}`

TODO: show how to ssh with the dcos cli, including proxying through the master to a private agent

https://dcos.io/docs/1.8/administration/sshcluster/

## Component Logs

Component List: <https://dcos.io/docs/1.8/overview/components/>

One of the most common logs to view are Marathon's because it handles deploying services.

To view Marathon's logs first SSH into a master node, then use journalctl:

```
$ journalctl -u dcos-marathon
```

To tail the logs, use `-f`:

```
$ journalctl -u dcos-marathon -f
```

Other components can be found using `systemctl`:

```
$ systemctl | grep dcos-
dcos-3dt.service               loaded active running   Diagnostics: DC/OS Distributed Diagnostics Tool Master API and Aggregation Service
dcos-adminrouter.service       loaded active running   Admin Router Master: A high performance web server and a reverse proxy server
dcos-cosmos.service            loaded active running   Package Service: DC/OS Packaging API
dcos-epmd.service              loaded active running   Erlang Port Mapping Daemon: DC/OS Erlang Port Mapping Daemon
dcos-exhibitor.service         loaded active running   Exhibitor: Zookeeper Supervisor Service
dcos-history.service           loaded active running   Mesos History: DC/OS Resource Metrics History Service/API
dcos-marathon.service          loaded active running   Marathon: DC/OS Init System
dcos-mesos-dns.service         loaded active running   Mesos DNS: DNS based Service Discovery
dcos-mesos-master.service      loaded active running   Mesos Master: DC/OS Mesos Master Service
dcos-metronome.service         loaded active running   Jobs Service: DC/OS Metronome
dcos-minuteman.service         loaded active running   Layer 4 Load Balancer: DC/OS Layer 4 Load Balancing Service
dcos-navstar.service           loaded active running   Navstar: A distributed systems & network overlay orchestration engine
dcos-oauth.service             loaded active running   OAuth: OAuth Authentication Service
dcos-pkgpanda-api.service      loaded active running   Pkgpanda API: Package Management Service
dcos-spartan.service           loaded active running   DNS Dispatcher: An RFC5625 Compliant DNS Forwarder
dcos-pkgpanda-api.socket       loaded active running   Pkgpanda API socket: Package Management Service Socket
dcos-adminrouter-reload.timer  loaded active waiting   Admin Router Reloader Timer: Periodically reload admin router nginx config to pickup new dns
dcos-gen-resolvconf.timer      loaded active waiting   Generate resolv.conf Timer: Periodically update systemd-resolved for mesos-dns
dcos-logrotate-master.timer    loaded active waiting   Logrotate Timer: Timer to trigger every 2 minutes
dcos-signal.timer              loaded active waiting   Signal Timer: Timer for DC/OS Signal Service
dcos-spartan-watchdog.timer    loaded active waiting   DNS Dispatcher Watchdog Timer: Periodically check is Spartan is working
```

Note that master and agent nodes have different components.

## Identify Marathon Leader

If your cluster has multiple master nodes (which it should, in production), current logs will only be on the leading master.
Since each HA component selects its own leader, marathon and mesos leaders may not be on the same master node.

Finding the leading Marathon is a bit tricky, but it is available in the Mesos `state.json`.

However, with authorization enabled, accessing the API programmatically is a bit more complicated.

One available method is to SSH into the master node, bypass the admin router (that enforces authorization) and curl Mesos directly.

The result can then be processed with jq to pull out the hostname of the registered Marathon framework.

```
dcos node ssh --leader --user=root --option IdentityFile=genconf/ssh_key $'curl "http://\$(hostname):5050/state.json"' 2>/dev/null | jq -r '.frameworks[] | select(.name == "marathon") | .hostname'
```

## Next Up

[DC/OS 104 - Service Discovery](dcos-104.md)
