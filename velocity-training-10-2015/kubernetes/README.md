# Kubernetes 101

Keep http://kubernetes.io/v1.0/ open in a browser, you'll need it.


## Install Kubernetes

Make sure you're in `$DCOS_CLI_HOME`. The, follow the instructions in https://docs.mesosphere.com/services/kubernetes/ to install Kubernetes:

    $ dcos config prepend package.sources https://github.com/mesosphere/multiverse/archive/version-1.x.zip
    $ dcos package update --validate
    $ dcos package install kubernetes

... and then [kubectl](https://docs.mesosphere.com/services/kubernetes/#a-namefivealaunch-a-kubernetes-pod-and-service-by-using-kubectl) from there as well.

Once you have Kubernetes as a service installed and `kubectl` the CLI on your local laptop, do:

    export KUBERNETES_MASTER=http://$DCOS_DASHBOARD_FQHN/service/kubernetes/api
    
... with `$DCOS_DASHBOARD_FQHN` being the FQHN of the DCOS dashboard URL.

## Inspect the Kubernetes UI

Visit http://$DCOS_DASHBOARD_FQHN/service/kubernetes/api/v1/proxy/namespaces/kube-system/services/kube-ui/ 

## Run a pod

    $ cd $DCOS_CLI_HOME
    $ kubectl run mh9-nginx --image=nginx --replicas=2 --port=80
    $ kubectl get pods
    $ kubectl delete rc mh9-nginx

## Run a service

    $ cd $DCOS_CLI_HOME
    $ kubectl create -f velocity-training/kubernetes/k8s-webserver-pod.json
    $ kubectl get pods
    $ kubectl create -f velocity-training/kubernetes/k8s-webserver-service.json
    $ kubectl get services
    NAME             LABELS                                    SELECTOR     IP(S)         PORT(S)
    k8sm-scheduler   component=scheduler,provider=k8sm         <none>       10.10.10.9    10251/TCP
    kubernetes       component=apiserver,provider=kubernetes   <none>       10.10.10.1    443/TCP
    nginx-service    name=nginx                                name=nginx   10.10.10.12   80/TCP

## Clean up

    $ cd $DCOS_CLI_HOME
    $ kubectl delete service nginx-service
    $ kubectl delete pod nginx
