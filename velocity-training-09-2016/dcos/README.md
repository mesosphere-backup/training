## Setup

1. Log in to DC/OS UI

    - Visit DC/OS cluster-specific URL in a browser
    - Log in with an OAuth account (like github)
    - First user will be made the admin user and need to create accounts for subsequent users

1. Install DC/OS CLI (from DC/OS UI)

    Follow instructions for installing the CLI (in the UI).
    ![Install CLI](dcos-cli-install.png)

1. Log in to DC/OS CLI

    ```
    $ dcos auth login
    ```

    Follow instructions to retrieve OAuth token via a browser.

1. SSH into DC/OS Cluster

    - Download SSH private key
    - Generate SSH public key: `ssh-keygen -y -f ~/.ssh/dcoskey > ~/.ssh/dcoskey.pub`
    - Set SSH private key permissions: `chmod 600 ~/.ssh/dcoskey`
    - Add SSH private key to SSH client: `ssh-add ~/.ssh/dcoskey`
    - SSH into remote machine: `ssh -A core@${MASTER_IP_ADDRESS}`

    TODO: use dcos cli?
    https://dcos.io/docs/1.8/administration/sshcluster/
