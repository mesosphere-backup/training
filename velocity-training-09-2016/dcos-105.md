# DC/OS 105 - Networking & Service Discovery

For general information on service discovery, see <https://dcos.io/docs/1.8/usage/service-discovery/>

## Agenda

- [Domain Name Service (DNS)](#domain-name-service-dns)
- [Reverse Proxy](#reverse-proxy)
- [Virtual Address](#virtual-address)
- [Overlay Network](#overlay-network)

## Domain Name Service (DNS)

Mesos-DNS will give every Mesos task a well known DNS name based on the scheduler that created the task.

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

### Mesos-DNS Resources

- DNS in DC/OS: <https://dcos.io/docs/1.8/usage/service-discovery/mesos-dns/>
- Mesos-DNS Website: http://mesosphere.github.io/mesos-dns/
- Mesos-DNS Source: https://github.com/mesosphere/mesos-dns

## Reverse Proxy

Marathon-LB is the standard reverse proxy used with DC/OS to expose public services.
It works by watching Marathon state changes and updating HAProxy to match.
It runs on a DC/OS **public agent node** and is itself scheduled by Marathon.

Marathon-LB can be installed from the Mesosphere Universe:

```
dcos package install marathon-lb
```

Since Marathon-LB can handle proxying a large number of services, it is allocated most of the open ports on the public agent node, including 80 (HTTP) and 443 (HTTPS). So it may fail to deploy if your public nodes already have other ports allocated.

On some older kernels (like CentOS), Marathon-LB may need to be configured before install to remove unsupported `sysctl-params` or it will fail to deploy.

To configure a service to use Marathon-LB:

1. Configure the service to run on a private agent node with a random host port:

    These settings are default behavior, but were set with explicit values in the MiniTwit example. Change or just remove them.

    Set the host port to zero:

    ```
    "container": {
      ...
      "docker": {
        ...
        "portMappings": [
          {
            ...
            "hostPort": 0,
          }
        ]
      }
    }
    ```

    Disable host port requirement:

    ```
    "requirePorts": false
    ```

    Remove the resource role requirement:

    ```
    "acceptedResourceRoles": []
    ```

1. Add a `servicePort` in the port mapping of a specific port:

   ```
   "container": {
     ...
     "docker": {
       ...
       "portMappings": [
         {
           ...
           "servicePort": 80
         }
       ]
     }
   }
   ```

   The service port should be set to the port to expose on the public agent node.

1. Label the service as external:

    ```
    "labels":{
      "HAPROXY_GROUP": "external"
    }
    ```

Once both the service and Marathon-LB are created or updated, the service should be accessible on the public agent node via the specified service port.

On AWS, the public agent nodes are given their own Elastic Load Balancer (ELB).
If there is only one public agent node, the ELB can be used to access Marathon-LB.

Otherwise, to find the Marathon-LB endpoint according to the cluster, use the dcos CLI (or web GUI or Marathon API):

```
# TODO: update for AWS
$ dcos marathon app show marathon-lb | jq -r .tasks[].host
172.17.0.6
```

Try accessing MiniTwit through Marahton-LB!

### Virtual Hosts

A virtual host is a fully qualified domain name (FQDN) assigned to a specific Marahton-LB port.
This allows you to serve from a non-standard port (e.g. 10000), but access with a standard port (e.g. 80).
This means you can serve many services from the same public agent node, each with their own custom domain or sub-domain!

Setting up a virtual host requires registering a domain name. So we'll skip it for this workshop.

For more detail, see <https://dcos.io/docs/1.8/usage/service-discovery/marathon-lb/usage/#virtual-hosts>

## Virtual Address

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

## Overlay Network

TODO: Overlay Networks

## Back to Index

[Velocity Training](README.md)
