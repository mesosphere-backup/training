# CI/CD with DCOS

The goal of this session is to use Jenkins on DCOS to build a very basic continuous integration and continuous delivery pipeline that builds an application and deploys it to Marathon.

### Pre-requisites

1. Docker Hub account
2. GitHub account
3. DCOS cluster
4. Installed DCOS CLI
5. gem, bundler (optional)

### Installing the Jenkins package

We're going to install an instance of Jenkins onto DCOS. The Jenkins package for DCOS is available in the [Mesosphere Universe](https://github.com/mesosphere/universe). Before we install it, we want to set some options.

First, go to the DCOS UI and grab the hostname of one of your private agent nodes. This is one which **doesn't** have the attribute public_ip true, e.g.:

<img src="http://cl.ly/1C2E3v2q243S/Image%202016-04-14%20at%201.41.14%20PM.png" width="25%">

Create a local JSON file with the following contents, called `jenkins.json`, replacing `1.2.3.4` with your own hostname:
```
{
  "jenkins": {
    "pinned-hostname": "1.2.3.4"
  }
}
```

Then install Jenkins using the DCOS CLI:
```
dcos package install --yes --options=jenkins.json jenkins
```

Wait a few minutes and the Jenkins instance should come up!

#### Installing the Marathon plugin

The Marathon plugin provides an easy way to deploy an application to Marathon.

To install it:

1. Download the `.hpi` file for the latest Marathon plugin here: https://github.com/mesosphere/jenkins-marathon-plugin/releases
2. Visit the Jenkins plugin manager and install via the "Advanced" tab.

<img src="http://cl.ly/2V2c3W2V3e1D/Image%202016-04-14%20at%201.58.23%20PM.png" width="50%">

#### Installing a Marathon instance

We're going to set up a new instance of Marathon. It's generally recommended that the Marathon that ships with DCOS isn't used to run "userland" applications, like the Jekyll web server we'll deploy in this tutorial.

Create a local JSON file with the following contents, called `marathon.json`:
```
{
  "marathon": {
    "framework-name": "marathon-dcos-bootcamp",
    "mesos-role": "slave_public"
  }
}
```

Then install Marathon using the DCOS CLI:
```
dcos package install --yes --options=marathon.json marathon
```

Wait a few minutes and the Marathon instance should come up! While you're in the DCOS Marathon UI, grab the IP address and port of the newly running Marathon framework - we'll need this at the very end.

This is shown underneath the task ID of the one running task.

<img src="http://cl.ly/0b3P1v2P3502/Image%202016-04-16%20at%207.08.28%20PM.png" width="50%">

### Setting up our project

Begin by creating a new public GitHub repository, e.g. ssk2/dcos-bootcamp-cd. Initialise this with a README and clone it to your computer.

<img src="http://f.cl.ly/items/3o0n2M3B0H0v1s102r2J/Image%202016-04-14%20at%201.28.48%20PM.png" width="50%">

When this is done, you can either generate a new site from scratch or re-use our existing site.

#### a) Creating a Jekyll site from scratch

Follow [the instructions provided by GitHub](http://www.stephaniehicks.com/githubPages_tutorial/pages/githubpages-jekyll.html) to create a basic site outline:

1. Let's go to your new repository:

        cd dcos-bootcamp-cd

2. Install bundler if you don't have it:

        gem install bundler

3. Install Jekyll if you don't have it:

        gem install jekyll

4. Initialise the site:

        jekyll new site

5. Add these files to your repository:

        git add site/*
        git commit -m "Site files"
        git push

#### b) Re-using our site

1. Let's go to your new repository:

        cd dcos-bootcamp-cd

2. Clone https://github.com/mesosphere/cd-demo
3. Copy the entire "site" folder over to your repo:

        cp -R cd-demo/site dcos-bootcamp-cd/site

4. Push this up to your repository:

        git add site/*
        git commit -m "Site files"
        git push

#### Creating a Docker Hub repo

Create a new public DockerHub repository, e.g. ssk2/dcos-bootcamp-cd.

<img src="http://f.cl.ly/items/1J1n0a2K1O2c0p0s0T11/Image%202016-04-14%20at%201.22.07%20PM.png" width="50%">

#### Creating a Dockerfile

Let's create a very simple `Dockerfile` that reuses a Jekyll base image and adds our files to it:

```
nano Dockerfile
```

And paste the following two lines into it:

```
FROM jekyll/jekyll
ADD site /srv/jekyll
```

Commit and push this file:

```
git add Dockerfile
git commit -m "Add Dockerfile"
git push
```

#### Creating a Marathon file

Now we'll add a file that describes how this application should run on Marathon.

Create `marathon.json` in the root of your repository:

```
nano marathon.json
```

Now put the following JSON into it. This specifies how the application should run, and will be used when we deploy to Marathon.

Don't forget to change the Docker image to point to your newly created Docker Hub repository.

```json
{
  "id": "cd-demo-app",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "ssk2/dcos-bootcamp-cd:latest",
      "network": "BRIDGE",
      "portMappings": [
        {
          "hostPort": 80,
          "containerPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  },
  "acceptedResourceRoles": [
    "slave_public"
  ],
  "labels": {
    "lastChangedBy": "sunil@mesosphere.io"
  },
  "instances": 1,
  "cpus": 0.1,
  "mem": 128,
  "healthChecks": [
    {
      "protocol": "TCP",
      "gracePeriodSeconds": 600,
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

```
git add marathon.json
git commit -m "Add marathon.json"
git push
```

### Setting up a pipeline

We will create a couple of jobs that depend on each other to create a basic build and deploy pipeline.

#### Adding Credentials

Go to the Credentials link on the left hand side, click on Global credentials and again on Add Credentials. Put your Docker Hub credentials in here.

<img src="http://f.cl.ly/items/0s1O0o1B380f0O1o3X0c/Image%202016-04-14%20at%201.47.35%20PM.png" width="50%">

#### Building Jekyll

Go to the running instance of Jenkins on your DCOS cluster and click on the "New Item" link.

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

    docker login -u ${DOCKER_HUB_USERNAME} -p ${DOCKER_HUB_PASSWORD} -e sunil@mesosphere.io


Step 2:

    docker build -t ssk2/dcos-bootcamp-cd:${GIT_COMMIT} .

Step 3:

    docker push ssk2/dcos-bootcamp-cd:${GIT_COMMIT}

<img src="http://cl.ly/131L460C3K36/Image%202016-04-14%20at%201.54.22%20PM.png" width="50%">

Finally, let's add a "Marathon Deployment" post build action. We'll use the IP address and hostname for the Marathon instance you installed earlier, e.g. `http://1.2.3.4:5678` (replacing 1.2.3.4 with the task's IP address and 5678 with the task's port).

<img src="http://cl.ly/2N3R3u1S1R46/Image%202016-04-17%20at%209.59.41%20AM.png" width="50%">

Hit save! Within the next minute, Jenkins will automatically build your project for the first time. (If you've already saved it, you'll need to hit "Build now" or commit a change for Jenkins to build the project again.)

### Viewing the Deployed Application

The application definition we used earlier specifies that Marathon should deploy to a DCOS agent with the role `slave_public` - i.e. a node with a public IP address.

You can check the status of the deployment from the dashboard of the Marathon instance you installed (accessible via the Services page of the DCOS UI). The first time you run it, it may take a bit of time to start as Docker pulls all the layers of the image - but subsequent deployments should be much quicker.

<img src="http://cl.ly/1a3n3k311X3z/Image%202016-04-16%20at%207.49.46%20PM.png" width="50%">

If you only have one public node, simply go to that node's DNS address in your browser to see our new Jekyll site running!

<img src="http://cl.ly/3Q0F3O2v1D0u/Image%202016-04-18%20at%207.09.53%20PM.png" width="50%">
