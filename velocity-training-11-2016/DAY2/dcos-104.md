# DC/OS 104 - Packages & Scaling

![DC/OS Universe](images/dcos-universe.png)

## Install MySQL

The MySQL universe package is a fairly simple package. It's just MySQL running in a docker container with a package that defines domain-specific configuration, using a template to generate a DC/OS service definition.

To install MySQL from the GUI:

1. Select `Universe` in the left navigation panel to access the package list page
1. Type `MySQL` into the search box to filter the packages.
1. Select `Install`, next to the MySQL package, to open the package install screen
1. Select `Advanced Installation` to open the package configuration screen
1. On the `mysql` tab, under `root_password`, enter a password (e.g. `root`)
1. On the `mysql` tab, under `name`, enter the name of a database to create on installation (e.g. `minitwit`)
1. On the `mysql` tab, under `username`, enter the name of a user to create with access to the database (e.g. `minitwit`)
1. On the `mysql` tab, under `password`, enter a password to assign to the new user (e.g. `minitwit`)
1. Select `Review and Install` to open the package review page
1. Select `Install` to install the package and create a DC/OS service

![MySQL Universe Package](images/dcos-install-mysql.png)

Packages may *alternatively* be installed with the DC/OS CLI, using a JSON configuration file.

```
$ cat > pkg-mysql.json << EOF
{
  "service": {
    "name": "mysql"
  },
  "mysql": {
    "cpus": 0.3,
    "mem": 512
  },
  "database": {
    "name": "minitwit",
    "username": "minitwit",
    "password": "minitwit",
    "root_password": "root"
  },
  "networking": {
    "port": 3306,
    "host_mode": true,
    "external_access": {
      "enable": false,
      "external_access_port": 13306
    }
  }
}
EOF

$ dcos package install mysql --options=pkg-mysql.json
```

Once installed, running, and ready, MySQL should be reachable inside the cluster via DNS at `mysql.marathon.mesos:3306`.

## Configure service to Use MySQL

By default, the MiniTwit service used in [DC/OS 103](dcos-103.md#readiness-checks) creates and uses an in-memory HyperSQL database (HSQLDB), but it can also be configured to use an external MySQL to preserve its data.

To configure MiniTwit to use MySQL, a few environment variables need to be configured in the MiniTwit service definition. For this, destroy the MiniTwit service and use the following service definition (either via the DC/OS CLI command `dcos marathon app add` or using the DC/OS UI):

```
{
  "id": "/minitwit",
  "instances": 1,
  "cpus": 1,
  "mem": 512,
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
  "env": {
    "SPRING_DATASOURCE_URL": "jdbc:mysql://mysql.marathon.mesos:3306/minitwit?autoReconnect=true&useSSL=false",
    "SPRING_DATASOURCE_USERNAME": "minitwit",
    "SPRING_DATASOURCE_PASSWORD": "minitwit",
    "SPRING_DATASOURCE_DRIVER-CLASS-NAME": "com.mysql.cj.jdbc.Driver",
    "SPRING_DATASOURCE_PLATFORM": "mysql"
  }
}
```

These are standard Spring JDBC environment variables used to specify a DataSource. Spring will auto-generate the appropriate DataSource object and inject it into classes that require one.

## Service suspension

As with most applications using an external database, MiniTwit can now be stopped and restarted without losing data.

To stop a DC/OS service:

1. Select `Services` in the left navigation panel to access the service list page
1. Hover over the name of the deployed service (e.g. `minitwit`) to show the service actions button
1. Select the service actions button to show a dropdown of service actions
1. Select `Suspend` to show the confirmation dialog
1. Select `Suspend Service` to scale the service down to zero instances

![Suspend Service](images/dcos-service-suspend.png)

Scaling to zero instances will gracefully terminate (TERM signal) all running instances, killing them (KILL signal) if graceful termination takes longer than the configured `taskKillGracePeriodSeconds`.

Once suspended, a service can be restarted by scaling it up to the desired number of instances.

## Load balancing with Marathon-LB

With externalized data storage, carefully designed (cloud native) web applications can be horizontally scaled to handle more traffic.

To scale a service, a load balancer is generally required, to feed incoming traffic to a service with capacity to handle it.

Marathon-LB is the standard reverse proxy used with DC/OS to expose public services.
It works by watching Marathon state changes and updating HAProxy to match.
It runs on a DC/OS **public agent node** and is itself scheduled by Marathon.

Marathon-LB can be installed as DC/OS package from the Mesosphere Universe:

```
dcos package install marathon-lb
```

![Marathon-LB](images/dcos-install-marathon-lb.png)

Since Marathon-LB can handle proxying a large number of services, it is allocated most of the open ports on the public agent node, including 80 (HTTP) and 443 (HTTPS). So it may fail to deploy if your public nodes already have ports allocated to other services.

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
    "acceptedResourceRoles": null
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

Once both the service and Marathon-LB are created/updated, running, and healthy, the service should be accessible on the public agent node via the specified service port.

On AWS, the public agent nodes are given their own Elastic Load Balancer (ELB).
If there is only one public agent node, the ELB can be used to access Marathon-LB.

To find the public IP address of the public agent node:

```
# Lookup the internal IP of the public agent node hosting marathon-lb
$ dcos marathon app show marathon-lb | jq -r .tasks[].host
10.0.6.199

# SSH into the leading master
$ dcos node ssh --master-proxy --leader

# SSH into the public agent node
$ ssh 10.0.6.199

# Lookup the public IP of the public agent node
$ curl -sf http://ipecho.net/plain
52.32.72.231
```

To see this in action, modify the MiniTwit service definition from [DC/OS 103](dcos-103.md#readiness-checks) to use Marahton-LB and expose port 80 as external. Then use the public IP or ELB to reach MiniTwit from your local machine.

## Service scaling

Now that MiniTwit is behind a load balancer, it can be scaled to an arbitrary number of instances to handle planned load.

![Service Scaling](images/dcos-service-scale.png)

Scaling a service is simple in DC/OS:

1. Select `Services` in the left navigation panel to access the service list page
1. Hover over the name of the deployed service (e.g. `minitwit`) to show the service actions button
1. Select the service actions button to show a dropdown of service actions
1. Select `Scale` to show the confirmation dialog
1. Enter the number of service instances to deploy in total (e.g. `3`)
1. Select `Scale Service` to start the deployment of new service instances

![Three Service Instances](images/dcos-service-detail-scaled.png)

Service may *alternatively* be scaled with the DC/OS CLI:

```
$ dcos marathon app update minitwit instances=3
```

Now, when accessing the service via the public slave, Marathon-LB will round robin between the healthy service instances!

If any of the service instances crash or become unreachable, Marathon-LB will remove them from load balancing ring automatically so that users are (almost) always sent to a healthy service instance.
