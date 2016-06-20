# CI/CD

The goal of this session is to use Jenkins on DC/OS to build a basic continuous integration and continuous delivery pipeline that builds an application and deploys it to Marathon.

### Pre-requisites

1. Docker Hub account
2. GitHub account
3. DC/OS cluster
4. Installed DC/OS CLI

### Installing  Jenkins

We're going to install an instance of Jenkins onto DC/OS. The Jenkins package for DCOS is available in the [Mesosphere Universe](https://github.com/mesosphere/universe). 

Install Jenkins using the DC/OS CLI:
```
dcos package install jenkins
```

Wait a few minutes and the Jenkins instance should come up and be available via the Services tab.

### Installing the Marathon plugin

The Marathon plugin provides an easy way to deploy an application to Marathon.

To install it:

1. Download the `.hpi` file for the latest Marathon plugin here: https://github.com/mesosphere/jenkins-marathon-plugin/releases
2. Visit the Jenkins plugin manager and install via the "Advanced" tab.

<img src="http://cl.ly/2V2c3W2V3e1D/Image%202016-04-14%20at%201.58.23%20PM.png" width="50%">

### Setting up our project

Begin by creating a new public GitHub repository, e.g. [mhausenblas/cicd-demo](https://github.com/mhausenblas/cicd-demo). Initialise this with a README and clone it to your machine. When this is done, you can either generate a new site from scratch or re-use our existing site.

#### a) Creating a Jekyll site from scratch

Follow [the instructions provided by GitHub](http://www.stephaniehicks.com/githubPages_tutorial/pages/githubpages-jekyll.html) to create a basic site outline:

    $ gem install bundler
    $ gem install jekyll
    $ jekyll new site

Now add these files to your repository:

    $ git add site/*
    $ git commit -m "inits site"
    $ git push

#### b) Re-using our site

Clone https://github.com/mhausenblas/cicd-demo and copy the entire `site` folder over to your repo and push this to your repository:

    $ git add site/*
    $ git commit -m "inits site"
    $ git push

#### Creating a Docker Hub repo

Create a new public DockerHub repository, e.g. [mhausenblas/cicd-demo](https://hub.docker.com/r/mhausenblas/cicd-demo/).

#### Creating a Dockerfile

Let's create a very simple `Dockerfile` that reuses a Jekyll base image and adds our files to it:

    FROM jekyll/jekyll
    ADD site /srv/jekyll

Commit and push this file:

    $ git add Dockerfile
    $ git commit -m "adds Dockerfile"
    $git push

#### Creating a Marathon file

Now we'll add a file that describes how this application should run on Marathon. For that, create a `blog.json` in the root of your repository and add the following JSON into it. This specifies how the application should run, and will be used when we deploy to Marathon. NOTE: don't forget to change the Docker image to point to your newly created Docker Hub repository!

```json
{
  "id": "myblog",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "mhausenblas/cicd-demo:latest",
      "network": "BRIDGE",
      "portMappings": [
        {
          "containerPort": 4000,
          "hostPort": 0
        }
      ]
    }
  },
  "acceptedResourceRoles": [
    "slave_public"
  ],
  "labels": {
    "lastChangedBy": "michael@dcos.io"
  },
  "instances": 1,
  "cpus": 0.1,
  "mem": 128,
  "healthChecks": [
    {
      "protocol": "TCP",
      "gracePeriodSeconds": 200,
      "intervalSeconds": 30,
      "portIndex": 0,
      "timeoutSeconds": 10,
      "maxConsecutiveFailures": 2
    }
  ],
  "upgradeStrategy": {
    "minimumHealthCapacity": 0
  }
}
```

Commit and push this file:


    $ git add marathon.json
    $ git commit -m "adds Marathon app spec"
    $ git push

### Setting up a pipeline

We will create a couple of jobs that depend on each other to create a basic build and deploy pipeline.

#### Adding Credentials

Go to the Credentials link on the left hand side, click on Global credentials and again on Add Credentials. Put your Docker Hub credentials in here.

<img src="http://f.cl.ly/items/0s1O0o1B380f0O1o3X0c/Image%202016-04-14%20at%201.47.35%20PM.png" width="50%">

#### Building Jekyll

Go to the running instance of Jenkins on your DC/OS cluster and click on the "New Item" link.

<img src="http://f.cl.ly/items/3m100B1T0D3J3W1I181w/Image%202016-04-14%20at%201.32.39%20PM.png" width="50%">

Create a "Freestyle project" and give it a meaningful name.

<img src="http://f.cl.ly/items/47390s2W0Y2I1o0V0y3l/Image%202016-04-14%20at%201.33.34%20PM.png" width="50%">

We'll set up our new git repo. Make sure you use the HTTPS URL.

<img src="http://cl.ly/0t1T312p0M0F/Image%202016-04-14%20at%201.38.05%20PM.png" width="50%">

Then, let's set up Jenkins to poll the repo, using the `* * * * *` schedule, which will poll every minute.

<img src="http://cl.ly/243p3e3r2P1W/Image%202016-04-14%20at%201.39.21%20PM.png" width="50%">

Now we need to bind our username and password to environment variables.

<img src="http://cl.ly/3I0y0G29062E/Image%202016-04-14%20at%201.49.49%20PM.png" width="50%">

Next, add three "Execute shell" build steps to login, build and push the image respectively. We will tag it with the Git commit SHA. Don't forget to put `#!/bin/bash` at the top of each of these commands.

Step 1:

    docker login -u ${DOCKER_HUB_USERNAME} -p ${DOCKER_HUB_PASSWORD} -e michae@dcos.io

Step 2:

    docker build -t mhausenblas/cicd-demo:${GIT_COMMIT} .

Step 3:

    docker push mhausenblas/cicd-demo:${GIT_COMMIT}

<img src="http://cl.ly/131L460C3K36/Image%202016-04-14%20at%201.54.22%20PM.png" width="50%">

Finally, let's add a "Marathon Deployment" post build action. We'll use the internal IP address of the System Marathon, that is `http://leader.mesos:8080`.

Hit save! Within the next minute, Jenkins will automatically build your project for the first time. (If you've already saved it, you'll need to hit "Build now" or commit a change for Jenkins to build the project again.)

### Viewing the Deployed Application

The application definition we used earlier specifies that Marathon should deploy to a DC/OS agent with the role `slave_public`, i.e. a node with a public IP address.

You can check the status of the deployment from the dashboard of the Marathon instance you installed (accessible via the Services page of the DC/OS UI). The first time you run it, it may take a bit of time to start as Docker pulls all the layers of the image - but subsequent deployments should be much quicker.