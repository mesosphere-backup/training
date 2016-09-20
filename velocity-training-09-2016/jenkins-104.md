# Jenkins 104 - Build Triggers

## SCM Polling

Until now, the created builds have had to be triggered manually.

One of the simplest ways to trigger builds is to poll the source repository for changes.

To enable source repository polling:

1. Select a job to open the job detail page
1. Select `Configure` in the left nav to open the job configuration page
1. Under `Build Triggers`, select `Poll SCM` to show the poll schedule section
1. Under `Poll SCM`, enter a `Schedule` in cron syntax (e.g. `*/5 * * * *` for every 5 minutes)
  - TODO: Github Rate Limit?
1. Select `Save` to confirm changes and return to the job detail page

The job will now automaticaly trigger within 5 minutes after pushing a new commit to the configured source repository.



## Webhooks

SCM Polling is definitely the most reliable and flexible way to trigger builds, but it's also a slow and causes unnecessary traffic, which may count against your GitHub rate limit.

A more responsive alternative is to use webhooks. With webhooks, the source repository needs to be configured to know how to reach Jenkins. It then triggers immediate job execution whenever it relieves a new commit. While this is almost always better, it does require that Jenkins be publicly accessible, which comes with its complications and security risks.

Enabling webhooks requires that Jenkins be accessible by GitHub without having to log into DC/OS.

The normal method to enable this is to use Marathon-LB Virtual Hosts, which exposes a DC/OS service on an externally accessible web domain. Unfortunately, we don't have any domains available for this lab. So we'll have to improvise.

Before making Jenkins publically accessible, it's probably a good idea to improve security first. If that's important to you, skip ahead to [DC/OS 105 - Security](dcos-105.md), set up Jenkins security, and come back.

To make Jenkins accessible on the public agent node:

1. Install Marathon-LB
1. Export the current Jenkins service definition:

    ```
    dcos marathon app show jenkins > jenkins.json
    ```
1. Edit `jenkins.json`:
    1. Remove status-only fields:
        - `tasks`
        - `version`
        - `versionInfo`
    1. Remove conflicting deprecated fields:
        - `fetch`
    1. Lookup the allocated ports:

        ```
        $ JENKINS_1_PORT=${cat jenkins.json | jq .portDefinitions[0].port}
        $ JENKINS_2_PORT=${cat jenkins.json | jq .portDefinitions[1].port}
        ```
    1. Add labels to configure Marathon-LB's reverse proxy:

        ```
        "labels": {
          ...
          "HAPROXY_GROUP": "external",
          "HAPROXY_0_PORT": "${JENKINS_1_PORT}",
          "HAPROXY_1_PORT": "${JENKINS_2_PORT}",
        }
        ```
1. Update the Jenkins service:

    ```
    dcos marathon app update jenkins < jenkins.json
    ```

Once the service deployment has completed, Jenkins should be accessible via HTTP on the public agent node IP using the first port from above. The second port is for HTTPS, which we haven't set up yet.

To enable webhooks in GitHub:

1. Navigate to the source repository in GitHub (e.g. https://github.com/karlkfi/minitwit)
1. Select `Settings` in the top nav to open the settings page
1. Select `Webhooks` in the left nav to open the webhooks page (may require re-authentication)
1. Under `Payload URL`, enter the webhook url with the pattern `http://${DCOS_ADDRESS}/service/${JENKINS_SERVICE_NAME}/ghprbhook/`
1. Select `Let me select individual events.` to show the event section
1. Select `Pull request` and `Issue comment` and deselect all other events
1. Select `Add Webhook` to confirm the webhook configuration

TODO: ghprbhook or github-webhook?
https://thepracticalsysadmin.com/setting-up-a-github-webhook-in-jenkins/
https://www.fourkitchens.com/blog/article/trigger-jenkins-builds-pushing-github

TODO: Uncheck `Prevent Cross Site Request Forgery exploits`?

To enable webhooks in Jenkins:

**Build Configuration**

1. Navigate to the Jenkins build configuration page
1. Select `Build when a change is pushed to GitHub`


**System Configuration**

1. Under `GitHub Pull Request Builder`
1. Next to `Credentials`, select `Add` and `Jenkins` (credential provider) to open the Jenkins Credentials Provider screen
1. Next to `Kind`, select `secret text` to show the secret token section
1. For `Secret`, enter your GitHub personal access token TODO: generate instructions
1. For `ID`, enter something descriptive to identify the credentials (e.g. `karlkfi github token`)
1. Select `Add` to confirm credentials creation and return to the settings page
1. From the `Credentials` dropdown, select the newly created credentials (by `ID`)
1. Select `Apply` to confirm the settings changes

**Validate System Configuration**

1. Under `GitHub Pull Request Builder`
1. Select `Test basic connection to GitHub` to show the connection test section
1. Select `Connect to API` to validate the GitHub credentials
1. Verify that the response text is not a red error

1. Navigate to the Jenkins build configuration page
1. Under `Build Triggers`, select `Build when a change is pushed to GitHub`

**Public Jenkins Access**

In order for Jenkins to be reachable by GitHub, it must be publicly accessible.

To configure the Jenkins DC/OS service to use Marathon-LB:

1. Switch to bridge networking with random container/host ports and fixed service ports:

    ```
    "container": {
      ...
      "docker": {
        ...
        "portMappings": [
          {
            "hostPort": 0,
            "containerPort": 80,
            "servicePort": 8080,
            "protocol": "tcp",
            "name": "http"
          },
          {
            "hostPort": 0,
            "containerPort": 443,
            "servicePort": 8081,
            "protocol": "tcp",
            "name": "https"
          }
        ],
        "network": "BRIDGE"
      }
    }
    ```

1. Enable require ports: TODO: why?

    ```
    "requirePorts": true
    ```

1. Label the service as external:

    ```
    "labels": {
      ...
      "HAPROXY_GROUP": "external"
    }
    ```

TODO: Webhooks (require a domain?)


Checkpoints (CloudBees paid feature): https://go.cloudbees.com/docs/cloudbees-documentation/cje-user-guide/chapter-workflow.html?q=checkpoints

Plugin:	GitHub Pull Request Plugin


`Integrations & services`:
`Jenkins (GitHub plugin`
`http://ec2-52-37-28-43.us-west-2.compute.amazonaws.com/service/jenkins/github-webhook/`

## Next Up

[Jenkins 105 - Security](jenkins-105.md)