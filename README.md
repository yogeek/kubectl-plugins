# Kubectl Plugins

Some useful [kubectl plugins](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/).

## Usage

```shell
USAGE:
  init-tiller <NAMESPACE>   : deploy and configure Tiller with RBAC in the given namespace
  init-tiller -h,--help     : show this message

  This plugin executes the following actions in the given namespace:
    - create a Service Account ("tiller-$namespace")
    - create a Role that allows Tiller to manage all resources of the namespace ("tiller-role-$namespace")
    - create a RoleBinding to link the SA and the Role ("tiller-rolebinding-$namespace")
    - deploy Tiller with the Service Account "tiller-$namespace"
```

## Installation

### Install with Curl (as root)

_For Kubernetes 1.12 or newer_

```shell
curl -Lo /usr/local/bin/kubectl-init-tiller https://raw.githubusercontent.com/yogeek/kubectl-plugins/master/init_tiller/init_tiller.sh 
chmod +x /usr/local/bin/kubectl-init-tiller
```

### Install with krew

1. [Install krew](https://github.com/GoogleContainerTools/krew) plugin manager for kubectl.
2. Run `kubectl krew install init-tiller`.
3. Start using by running `kubectl init-tiller NAMESPACE`.

#### Update with krew

*Warning* : NOT AVAILABLE YET => cf. `Install with curl` method
_This plugin has not been added to [krew index](https://github.com/GoogleContainerTools/krew-index/pull/87) yet._

Krew makes update process very simple. To update to latest version run

```shell
kubectl krew upgrade init-tiller
```

## Try the plugin

```shell
# create a namespace
$ kubectl create ns myns

# Deploy Tiller into the namespace
$ kubectl init-tiller myns

```