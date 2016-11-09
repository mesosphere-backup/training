# DC/OS 106 Troubleshooting 

Why are the following apps not deploying or can not be launched? What's wrong with them and how can you fix them?

Hint: sometimes it will be necessary to look at the Mesos UI (via `$DASHBOARD_URL/mesos`) to figure out what's going on.

## Exercise 1

    {
        "id": "ex1",
        "instances": 2,
        "cpus": 0.1,
        "mem": 100,
        "container": {
            "type": "DOCKER",
            "docker": {
                "image": "nginx:1.9",
                "network": "BRIDGE",
                "portMappings": [
                    {
                        "containerPort": 80,
                        "hostPort": 0
                    }
                ]
            }
        },
        "constraints": [["hostname", "UNIQUE"]],
        "acceptedResourceRoles": [
            "slave_public"
        ]
    }

## Exercise 2

    {
          "id": "ex2",
          "cpus": 1,
          "instances": 1,
          "mem": 512,
          "container": {
            "type": "DOCKER",
            "volumes": [
              {
                "containerPath": "pgdata",
                "mode": "RW",
                "persistent": {
                  "size": 100
                }
              }
            ],
            "docker": {
              "image": "postgres:latest",
              "network": "BRIDGE",
              "portMappings": [
                {
                  "containerPort": 5432,
                  "hostPort": 0,
                  "protocol": "tcp",
                  "name": "postgres"
                }
              ]
            }
          },
          "env": {
            "POSTGRES_PASSWORD": "password",
            "PGDATA": "pgdata"
          },
          "residency": {
            "taskLostBehavior": "WAIT_FOREVER"
          },
          "upgradeStrategy": {
            "maximumOverCapacity": 0,
            "minimumHealthCapacity": 0
          },
          "acceptedResourceRoles": [
                "slave_public"
          ]
    }

## Exercise 3


    {
      "id": "ex3",
      "instances": 1,
      "cpus": 0.1,
      "mem": 300,
      "container": {
        "type": "DOCKER",
        "docker": {
          "image": "mattermost/platform",
          "network": "BRIDGE",
          "portMappings": [
            {
              "containerPort": 80,
              "hostPort": 80
            }
          ]
        }
      },
      "acceptedResourceRoles": [
        "slave_public"
      ]
    }

## Even more …

Have a look at StackOverflow at questions tagged with `marathon`: http://stackoverflow.com/questions/tagged/marathon



