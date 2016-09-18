# Jenkins 103 - Persistent Storage

Since Jenkins master state is not persisted to an external database, and Jenkins masters are not easily horizontally scalable (which would distribute risk), it becomes imperative that the Jenkins state be persisted at the disk layer.

DC/OS has three types of persistent storage options:

1. External Volumes (experimental)
1. Local Volumes Reservation
1. Host Mounted Volumes

A persistent external volume would be ideal for this particular use case, using a distributed block store like AWS Elastic Block Store (EBS) or Ceph to host Jenkins state would gaurd against Jenkins and machine failure. Unfortunately, the persistent storage integration for DC/OS is still experimental and not enabled by default.

A local volume reservation is usually used for cloud native distributed services, where the data is already distributed and doesn't need to be persisted by an external system. It primarily protects against the cost of data replication. If a service instance dies but the DC/OS node it was running on is still available, the service instance would be brought up again to run on the same node with the same volume mount and data it had before. This won't guard against node failure, but is often good enough for systems with built-in redundancy, especially when combined with other data replication strategies, like persistent storage backed nodes, node drive backups, and periodic service-specific remote backups for disaster recovery.

A host mounted volume would also work for this use case, mounting a shared filesystem (like NFS) between several DC/OS agent nodes, constraining Jenkins to only run on those nodes, and mounting the shared filesystem into the Jenkins master container.

For simplicity, a host mounted volume will be used for this lab, without a backing shared filesystem or persistent external storage. Constraining the Jenkins master to only run on one node will ensure that if Jenkins crashes the state data will be recovered automatically.

To configure the Jenkins package with a host mounted volume:

```
$ cat > pkg-jenkins.json << EOF
{
  "service": {
    "name": "jenkins"
  },
  "storage": {
    "host-volume": "/mnt/nfs/jenkins_data"
  }
}
EOF
$ dcos package install jenkins --options=pkg-jenkins.json
```
