#!/usr/bin/env bash

# Requires:
# - kubectl
# - kubens
# - helm
set -eo pipefail

usage() {
  cat <<"EOF"
USAGE:
  init-tiller <NAMESPACE>   : deploy and configure Tiller with RBAC in the given namespace
  init-tiller -h,--help     : show this message

  This plugin executes the following actions in the given namespace:
    - create a Service Account ("tiller-${namespace}")
    - create a Role that allows Tiller to manage all resources of the namespace ("tiller-role-${namespace}") 
    - create a RoleBinding to link the SA and the Role ("tiller-rolebinding-${namespace}")
    - deploy Tiller with the Service Account "tiller-${namespace}"
EOF
}


main() {

  # Check kubectl
  if ! hash kubectl 2>/dev/null; then
    echo >&2 "kubectl is not installed"
    exit 1
  fi

  # Check kubens  
  if ! hash kubens 2>/dev/null; then
    echo >&2 "kubens is not installed"
    echo "(cf. https://github.com/ahmetb/kubectx/blob/master/README.md#linux)"
    exit 1
  fi

  # Check helm  
  if ! hash helm 2>/dev/null; then
    echo >&2 "helm CLI is not installed"
    echo "(cf. https://github.com/helm/helm/blob/master/docs/install.md#installing-the-helm-client)"
    exit 1
  fi

  # Parse args
  if [[ "$#" -eq 0 ]]; then
      # echo "TODO : display namespace without Tiller installed"
      usage
      exit 1
  elif [[ "$#" -eq 1 ]]; then
    if [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
      usage
      exit 1
    # elif [[ "${1}" == "all" ]]; then
    #   init_all_namespace
    else
      namespace=${1}
    fi
  else
    echo "error: too many flags" >&2
    usage
    exit 1
  fi

  echo "Working on ${namespace} namespace..."

  # Switch to namespace
  kubens ${namespace}

  # Init resources names
  sa_name="tiller-${namespace}"
  role_name="tiller-role-${namespace}"
  rolebinding_name="tiller-rolebinding-${namespace}"

  # Create Service Account for Tiller in the namespace
  if [[ "$(kubectl get sa --field-selector metadata.name=${sa_name})" != "" ]]; then
    echo "ServiceAccount '${sa_name}' already exists."
  else
    kubectl create serviceaccount "tiller-${namespace}" --namespace ${namespace}
  fi

  # Create Role for Tiller in the namespace
  if [[ "$(kubectl get role --field-selector metadata.name=${role_name})" != "" ]]; then
    echo "Role '${role_name}' already exists."
  else
    kubectl create role "tiller-role-${namespace}" \
      --namespace ${namespace} \
      --verb=* \
      --resource=*.,*.apps,*.batch,*.extensions
  fi

  # Create Rolebinding between Service Account and Role in the namespace
  if [[ "$(kubectl get rolebinding --field-selector metadata.name=${rolebinding_name})" != "" ]]; then
    echo "RoleBinding '${rolebinding_name}' already exists."
  else
    kubectl create rolebinding "${rolebinding_name}" \
      --namespace ${namespace} \
      --role="tiller-role-${namespace}" \
      --serviceaccount="${namespace}:tiller-${namespace}"
  fi

  # Deploy Tiller with the Service Account in the namespace
  helm init \
    --service-account "${sa_name}" \
    --tiller-namespace ${namespace} \
    --override "spec.template.spec.containers[0].command'='{/tiller,--storage=secret}" \
    --upgrade \
    --wait \

  echo "---------------------------------------------------"
  echo "Tiller has been deployed with RBAC in ${namespace}"

  echo "Example to test it :" 
  echo "\$ helm repo update"
  echo "\$ helm install stable/mysql --name mymysql --tiller-namespace ${namespace} --wait"
  echo "\$ helm list --tiller-namespace ${namespace}"
  echo "\$ helm delete mymysql --tiller-namespace ${namespace}"
  echo "---------------------------------------------------"

}

main "$@"