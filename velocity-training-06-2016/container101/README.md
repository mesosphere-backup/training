# Container & Docker 101

There are a few [valuable Docker](http://www.nkode.io/2014/08/24/valuable-docker-links.html) links out there.

## Install

Make sure you have access to your DC/OS cluster. Also, you'll need the public SSH key that you can derive from your private one using, for example, `ssh-keygen -y -f ~/.ssh/dcoskey > ~/.ssh/dcoskey.pub`

We will carry out the Docker-specific exercises via the DC/OS Master. It is a [CoreOS](https://coreos.com/) environment, so Docker native. To get onto the DC/OS Master do the following:

    # use the SSH key
    $ chmod 600 ~/.ssh/dcoskey
    # add key once:
    ssh-add ~/.ssh/dcoskey
    # log in with forwarding enabled (so that you can log in from master to one of the agents)
    ssh -A core@MASTER_IP_ADDRESS

If you have issues getting into the Master, check out https://dcos.io/docs/1.7/administration/sshcluster/ or ask one of the proctors.

## Find Docker images
    
    $ docker images
    $ docker search ubuntu

## Run Docker containers
    
    $ docker run -t -i ubuntu:14.04 /bin/bash
    # play around in the Ubuntu container and exit again
    $ docker ps -a

## Introspect Docker containers

    $ docker run -d ubuntu:14.04 tail -f /dev/null 
    # note the container ID of your Ubuntu container
    $ docker exec -it $CONTAINER_ID sh
    $ docker logs $CONTAINER_ID
    $ docker inspect $CONTAINER_ID
    $ docker kill $CONTAINER_ID 

## Build Docker images

    $ mkdir -p mh9test/nginx
    $ cd mh9test/nginx
    $ touch Dockerfile
    $ cat > Dockerfile <<EOF
    FROM nginx
    MAINTAINER Michael Hausenblas <michael@dcos.io>
    RUN apt-get update && apt-get install -y git
    RUN echo "I just built my first Docker image \o/" >> /usr/share/nginx/html/index.html
    EOF
    $ docker build -t mh9test/nginx:v2 .
    $ docker run -d -p 8081:80 mh9test/nginx:v2

## Pull and push Docker images to a registry

    $ docker pull ubuntu:latest

Make sure the repo exists under your account, say https://hub.docker.com/u/mhausenblas/ and then:
    
    $ docker login
    $ docker images
    REPOSITORY             TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    m-shop-app             latest              5891be3406d7        19 hours ago        349.8 MB
    ...
    $ docker tag 5891be3406d7 mhausenblas/m-shop-app 
    $ docker push mhausenblas/m-shop-app

## Clean up Docker images and containers

    $ docker rm -v $(docker ps -a -q -f status=exited)
    $ docker rmi $(docker images -f "dangling=true" -q)
