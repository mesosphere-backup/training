# Container 101

Tested with Docker engine v1.11, you might see unexpected results with 1.12 and above.

Note that the commands shown below assume a bash shell (so, this does not work on the Windows command line!).

## Find images

```
$ docker images
$ docker search ubuntu
$ docker search nginx
```

## Run one-off job

```
$ docker run --rm ubuntu:14.04 /bin/echo 'Hello world'
```

## Run interactively

```
$ docker run --rm -it ubuntu:14.04 /bin/bash
$ echo 'Hello world'
$ exit
```

## Run daemon

```
$ docker run -d -P --name my-nginx nginx

# list running containers
$ docker ps

# get container IP
$ NGINX_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' my-nginx)

# visit container address
$ curl http://${NGINX_IP}

# stop and remove container
$ docker rm -f my-nginx
```

## Introspect

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

## Build an image

```
$ mkdir -p demo/nginx
$ cd demo/nginx

# create a web page
$ echo "I just built my first Docker image \o/" > index.html

# create Dockerfile
$ cat > Dockerfile << EOF
FROM nginx
RUN apt-get update && apt-get install -y git
ADD index.html /usr/share/nginx/html/index.html
EOF

# log in to docker hub (not required for build, just getting username)
$ docker login

# get username
$ DOCKER_USER=$(docker info | grep Username | cut -d' ' -f2 | tee /dev/stderr)

# build docker image
$ docker build -t ${DOCKER_USER}/nginx-hello-world .
```

## Push and pull images

```
# publish image
$ docker push ${DOCKER_USER}/nginx-hello-world

# download published image
$ docker pull ${DOCKER_USER}/nginx-hello-world
```

## Push a specific image version

When no image tag version is specified, `latest` is used by default.

```
# tag latest image with a fixed version
$ docker tag ${DOCKER_USER}/nginx-hello-world:latest ${DOCKER_USER}/nginx-hello-world:1.0.0

# publish image
$ docker push ${DOCKER_USER}/nginx-hello-world:1.0.0

# download published image
$ docker pull ${DOCKER_USER}/nginx-hello-world:1.0.0
```

Visit your container page on DockerHub: `https://hub.docker.com/r/${DOCKER_USER}/nginx-hello-world/`


## Clean up

```
# force delete all containers
$ docker ps -q -a | xargs docker rm -f

# delete all unused images
$ docker images -f "dangling=true" -q | xargs docker rmi
```

Other, less destructive clean up options:

```
# delete all stopped containers
$ docker ps -a -q -f status=exited | xargs docker rm -v
```


