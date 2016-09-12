## DC/OS 101 -

## Intro

- Website: <https://dcos.io/>
- Source: <https://github.com/dcos/dcos>
- Docs: <https://dcos.io/docs/1.8/>
- Install Instructions: <https://dcos.io/install/>
- Release Notes & Downloads: <https://dcos.io/releases/>
- DC/OS Intro Video: <https://mesosphere.com/resources/dcos-demo/>

## Client Setup

1. Log in to the DC/OS UI

    - Visit DC/OS cluster-specific URL in a browser
    - Log in with an OAuth account (like github)
    - First user will be made the admin user and need to create accounts for subsequent users

1. Install the DC/OS CLI

    Follow the platform-specific instructions in the UI for installing and configuring the CLI.
    ![Install CLI](dcos-cli-install.png)

    Use the Linux instructions if you're SSHed into a Linux VM.

    TODO: do the Windows instructions work in GitBash?

1. Log in to the DC/OS CLI

    ```
    $ dcos auth login
    ```

    Follow instructions to retrieve OAuth token via a browser.

## Debugging

### SSH Access

If at any point you need to debug a DC/OS component, job, or service, you may need to SSH into the cluster.

Since not all of the machines in a production cluster are publically internet accessible, you may need to use a bootstrap or master node as a jump box.

- Download SSH private key
- Generate SSH public key: `ssh-keygen -y -f ~/.ssh/dcoskey > ~/.ssh/dcoskey.pub`
- Set SSH private key permissions: `chmod 600 ~/.ssh/dcoskey`
- Add SSH private key to SSH client: `ssh-add ~/.ssh/dcoskey`
- SSH into remote machine: `ssh -A core@${MASTER_IP_ADDRESS}`

TODO: use dcos cli?
https://dcos.io/docs/1.8/administration/sshcluster/
