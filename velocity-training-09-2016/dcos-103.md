# DC/OS 103 - Health Checks & Debugging

## Health Checks

TODO: marathon health checks

## SSH Access

If at any point you need to debug a DC/OS component, job, or service, you may need to SSH into the cluster.

Since not all of the machines in a production cluster are publically internet accessible, you may need to use a bootstrap or master node as a jump box.

- Download SSH private key
- Generate SSH public key: `ssh-keygen -y -f ~/.ssh/dcoskey > ~/.ssh/dcoskey.pub`
- Set SSH private key permissions: `chmod 600 ~/.ssh/dcoskey`
- Add SSH private key to SSH client: `ssh-add ~/.ssh/dcoskey`
- SSH into remote machine: `ssh -A core@${MASTER_IP_ADDRESS}`

TODO: use dcos cli?
https://dcos.io/docs/1.8/administration/sshcluster/

## Next Up

[DC/OS 104 - Service Discovery](dcos-104.md)
