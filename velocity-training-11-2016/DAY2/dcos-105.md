# DC/OS 105 - Networking & Service Discovery

For general information on service discovery, see https://dcos.io/docs/1.8/usage/service-discovery/


## Domain Name Service (DNS)

[Mesos-DNS](https://github.com/mesosphere/mesos-dns), one of the ~40 DC/OS system components, will give every Mesos task a well known DNS name based on the scheduler that created the task.

All nodes in a DC/OS cluster are configured to resolve DNS with Mesos-DNS. So while these DNS records will resolve inside the cluster, they wont resolve on your local machine without reconfiguring your DNS resolvers.

In general, the pattern is:

```
<task>.<scheduler>.mesos
```

DC/OS service tasks, which are scheduled by Marathon, will have the following DNS name pattern:

```
<service-name>.marathon.mesos
```

For example, a DC/OS service with the name `minitwit` will be reachable on `minitwit.marathon.mesos`.

The full list of DNS records can be queried from the Mesos-DNS API:

```
# SSH into a node (e.g. master)
dcos node ssh --leader --user=root --option IdentityFile=genconf/ssh_key

# curl the enumerate endpoint
curl -s -f http://master.mesos:8123/v1/enumerate
```

### Mesos-DNS resources

- DNS in DC/OS: <https://dcos.io/docs/1.8/usage/service-discovery/mesos-dns/>
- Mesos-DNS Website: http://mesosphere.github.io/mesos-dns/
- Mesos-DNS Source: https://github.com/mesosphere/mesos-dns

### Virtual hosts

A virtual host is a fully qualified domain name (FQDN) assigned to a specific Marahton-LB port.
This allows you to serve from a non-standard port (e.g. 10000), but access with a standard port (e.g. 80).
This means you can serve many services from the same public agent node, each with their own custom domain or sub-domain!

Setting up a virtual host requires registering a domain name. So we'll skip it for this lab.

For more detail, see <https://dcos.io/docs/1.8/usage/service-discovery/marathon-lb/usage/#virtual-hosts>

## Virtual address

A virtual address is a static Virtual IP (VIP) with an optional address name. Both the IP and the name may be specified per port in the service configuration. Multiple service ports can be configured to share the same virtual address.

VIPs provide load balancing between multiple instances of the same service. This is functionally similar to a [Layer 7](https://en.wikipedia.org/wiki/OSI_model#Layer_7:_Application_Layer) reverse proxy like Marathon-LB, except it's managed by much lower cost [Layer 4](https://en.wikipedia.org/wiki/OSI_model#Layer_4:_Transport_Layer) client-side IP rewriting.

VIPs may also be useful as a service discovery mechanism for services that cannot be configured after deployment.

Because VIPs are managed by a daemon that runs on the DC/OS nodes, only cluster internal processes can use it.

To configure a virtual IP, label a service port:

```
"container": {
  ...
  "docker": {
    ...
    "portMappings": [
      {
        ...
        "name": "http-api",
        "containerPort": 80,
        "labels": {
          "VIP_0": "172.16.0.1:80"
        }
      }
    ]
  }
}
```

This will make the specified container port accessible at `172.16.0.1:80` inside the cluster.

```
# SSH into a node (e.g. master)
$ dcos node ssh --leader --user=root --option IdentityFile=genconf/ssh_key

# use the VIP
$ curl -s -L -f http://172.16.0.1:80/
```

To configure a named virtual address (with an auto-generated VIP), label a service port:

```
"container": {
  ...
  "docker": {
    ...
    "portMappings": [
      {
        ...
        "name": "http-api",
        "containerPort": 80,
        "labels": {
          "VIP_0": "minitwit:80"
        }
      }
    ]
  }
}
```

In order to make sure the virtual address is unique within the cluster, the following pattern is used:

```
<vip-name>.<scheduler>.l4lb.thisdcos.directory:<vip-port>
```

This will make the specified container port accessible at `minitwit.marathon.l4lb.thisdcos.directory:80` inside the cluster.

```
# SSH into a node (e.g. master)
$ dcos node ssh --leader --user=root --option IdentityFile=genconf/ssh_key

# use the virtual address
$ curl -s -L -f http://minitwit.marathon.l4lb.thisdcos.directory:80/
```

For more detail about VIPs, see <https://dcos.io/docs/1.8/usage/service-discovery/load-balancing-vips/>

## Overlay network

An DC/OS overlay network is a virtual network that provides ephemeral IPv4 IPs to all containers (Mesos tasks) that opt-in. This is also known as IP-per-container.

By default, these overlay network IPs can be accessed from anywhere in the cluster, as if each container was on the same physical switch.

In addition, network isolation may also be configured such that only services on the same network and in the same virtual group may communicate with each other via their overlay network IPs.

Unlike virtual addresses, overlay networks use auto-assigned IPs, not IPs specified by the service owner. However, this means they also won't ever overlap with other services.

By default, DC/OS comes with one overlay network spanning all nodes named `dcos`, but additional overlay networks may be added by modifying the `config.yaml` before installation.

To configure a DC/OS service to be on an overlay network, specify one under `ipAddress`:

```
"ipAddress":{
  "networkName": "dcos"
}
```

To configure network isolation, add a `group`:

```
"ipAddress":{
  "networkName": "dcos",
  "groups": [ "secret-club" ]
}
```

Since the overlay network IP is only used by the task it's assigned to, no ports explicitly need to be allocated to the task. But if not using docker container port mapping, ports may be defined on the overlay IP address instead.

```
"ipAddress":{
  "networkName": "dcos",
  "discovery": {
    "ports": [
      {
        "name": "http-api",
        "number": 80,
        "protocol": "tcp"
      }
    ]
  }
}
```

**Caveats:**

- Because DC/OS overlay networks are new, they don't yet support mapping directly to a VIP. If you need a VIP too, you'll have to define a VIP using container port mapping instead (`container.docker.portMappings`).
- Overlay networking does not work concurrently with Marathon-LB. If you need both IP-per-container and a remote proxy, use a VIP and a static HAProxy or nginx that proxies to the VIP.
- If using docker container port mapping, ports cannot also be specified on the overlay IP address.
- If ports are specified on the overlay IP address, Marathon needs to have access to the specified overlay network in order to perform health and readiness checks.
- Marathon-LB does not currently work for services that are on an overlay network. This may change in the future.

For more detail about overlay networks, see https://dcos.io/docs/1.8/administration/overlay-networks/

