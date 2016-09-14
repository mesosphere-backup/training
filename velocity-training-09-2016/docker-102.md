# Docker 102 - Example Web App

MiniTwit is a very basic Twitter clone, writen in Java and using a variety of technologies familiar to enterprise developers.

MiniTwit is already Dockerized and published on DockerHub, but as an exercise we're going to fork it, modify it, and publish our own version.

## Agenda

- [Fork Repo](#fork-repo)
- [Clone Repo](#clone-repo)
- [Build Docker Image](#build-docker-image)
- [Run on Docker](#run-on-docker)
- [Discover Container IP](#discover-container-ip)
- [View Container Logs](#view-container-logs)
- [Stop Container](#stop-container)
- [Run on Docker with MySQL](#run-on-docker-with-mysql)
- [Cleanup](#cleanup)

## Fork Repo

1. Visit the GitHub repo in a browser: <https://github.com/karlkfi/minitwit>
1. Select `Fork` to open the fork screen
1. Select a user or organization to copy the repo into

    The user or organization you choose will be referred to as `${GITHUB_USER}` later in this document.

## Clone Repo

```
$ mkdir -p ~/workspace
$ cd ~/workspace
$ git clone https://github.com/${GITHUB_USER}/minitwit
$ cd minitwit
```

## Build Docker Image

```
$ docker build -t ${DOCKER_USER}/minitwit .
```

If you don't know your `DOCKER_USER`, see the instructions in [Docker 101: Build Docker Image](dcos-102.md#build-docker-image).

## Run on Docker

```
$ docker run -d --name minitwit ${DOCKER_USER}/minitwit
```

## Discover Container IP

```
$ docker inspect --format '{{ .NetworkSettings.IPAddress }}' minitwit
```

## View Container Logs

```
# print logs (STDOUT & STDERR)
$ docker logs minitwit

# print and tail the logs
$ docker logs minitwit -f
```

## Stop Container

```
# stop container (could be started again later)
$ docker stop minitwit

# remove container (delete record and logs)
$ docker rm minitwit
```

## Run on Docker with MySQL

MiniTwit optionally depends on MySQL for data persistence.

```
# create mysql environment file
$ cat > mysql.env << EOF
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=minitwit
MYSQL_USER=minitwit
MYSQL_PASSWORD=minitwit
EOF

# start mysql server
$ docker run -d --name=mysql --env-file=mysql.env mysql:5.7.15

# find mysql IP
$ MYSQL_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mysql)

# create minitwit environment file
$ cat > minitwit.env << EOF
SPRING_DATASOURCE_URL=jdbc:mysql://${MYSQL_IP}:3306/minitwit?autoReconnect=true&useSSL=false
SPRING_DATASOURCE_USERNAME=minitwit
SPRING_DATASOURCE_PASSWORD=minitwit
SPRING_DATASOURCE_DRIVER-CLASS-NAME=com.mysql.cj.jdbc.Driver
SPRING_DATASOURCE_PLATFORM=mysql
EOF

# start minitwit server
$ docker run -d --name minitwit --env-file=minitwit.env karlkfi/minitwit
```

## Cleanup

```
# stop and remove both containers
$ docker rm -f minitwit mysql
```

## Back to Index

[Velocity Training](README.md)
