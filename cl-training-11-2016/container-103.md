# Container 102

In this lab we focus on the underlying technologies: namespaces, cgroups, and COW filesystems.

Note that the following requires Linux, that is either natively or a VM running Linux.

## Install cinf

We will use [cinf](https://github.com/mhausenblas/cinf) to explore namespaces and cgroups.

```
$ curl -s -L https://github.com/mhausenblas/cinf/releases/download/v0.4.0-alpha/cinf -o cinf
$ sudo mv cinf /usr/local/bin
$ sudo chmod +x /usr/local/bin/cinf
$ sudo cinf
```

## Explore namespaces and cgroups

Either follow this [walkthrough](https://github.com/mhausenblas/cinf/blob/master/walkthrough.md) or launch your own favourite containers and explore the underlying namespaces and cgroups.

## Explore image content

```
$ docker run -d nginx:1.9
$ docker ps
$ docker export -o nginx-content.tar ${CONTAINER_ID}
$ mkdir explore-image && mv nginx-content.tar explore-image/ && cd explore-image/
$ tar -xvf nginx-content.tar
```