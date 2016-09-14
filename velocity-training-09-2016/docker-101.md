# Docker 101 - Containers & Images

## Agenda

- [Find Docker Images](#find-docker-images)
- [Run Docker Job](#run-docker-job)
- [Run Interactive Docker Container](#run-interactive-docker-container)
- [Run Docker Service](#run-docker-service)
- [Introspect Docker Containers](#introspect-docker-containers)
- [Build Docker Image](#build-docker-image)
- [Push & Pull Docker Image to DockerHub](#push--pull-docker-image-to-dockerhub)
- [Clean Up](#clean-up)

## Find Docker Images

```
$ docker images
$ docker search ubuntu
$ docker search nginx
```

## Run Docker Job

```
$ docker run --rm ubuntu /bin/echo 'Hello world'
```

## Run Interactive Docker Container

```
$ docker run --rm -t -i ubuntu:14.04 /bin/bash
$ echo 'Hello world'
$ exit
```

## Run Docker Service

```
$ docker run -d --name my-nginx nginx

# list running containers
$ docker ps

# get container IP
$ NGINX_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' my-nginx)

# visit container port
$ curl http://${NGINX_IP} #TODO: port? 8081? 8080? 80?

# stop and remove container
$ docker rm -f my-nginx
```

## Introspect Docker Containers

```
$ docker run -d --name my-ubuntu ubuntu:14.04 tail -f /dev/null

# Shell into running container
$ docker exec -it my-ubuntu /bin/bash
$ echo 'Hello world'
$ exit

# get the STDOUT & STDERR from the container
$ docker logs my-ubuntu

# get details about the running container
$ docker inspect my-ubuntu

# kill and remove container
$ docker rm -f my-ubuntu
```

## Build Docker Image

```
$ mkdir -p demo/nginx
$ cd demo/nginx

# create a web page
$ echo "I just built my first Docker image \o/" >> index.html

# create Dockerfile
$ touch Dockerfile
$ cat > Dockerfile <<EOF
FROM nginx
RUN apt-get update && apt-get install -y git
ADD index.html /usr/share/nginx/html/index.html
EOF

# log in to docker hub (not required for build, just getting getting username)
$ docker login

# get username
$ DOCKER_USER=$(docker info | grep Username | cut -d' ' -f2)

# build docker image
$ docker build -t ${DOCKER_USER}/nginx-hello-world .
```

## Push & Pull Docker Image to DockerHub

```
# tag existing image (skip if tagged at build time)
$ docker tag ${CONTAINER_ID} ${DOCKER_USER}/nginx-hello-world

# publish image
$ docker push ${DOCKER_USER}/nginx-hello-world

# download published image
$ docker pull ${DOCKER_USER}/nginx-hello-world
```

Visit your container page on DockerHub: `https://hub.docker.com/u/${DOCKER_USER}/nginx-hello-world/`

## Clean Up

```
# delete all stopped containers
$ docker ps -a -q -f status=exited | xargs docker rm -v

# force delete all containers
$ docker ps -q -a | xargs docker rm -f

# delete all unused images
$ docker images -f "dangling=true" -q | xargs docker rmi
```

## Next Up

[Docker 102 - Example Web App](dcos-102.md)
