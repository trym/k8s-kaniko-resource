#!/bin/bash
set -e

setup_kubernetes() {
  payload=$1
  source=$2

  # Setup kubectl
  k8s_cluster_url=$(jq -r '.source.k8s_cluster_url // ""' < $payload)
  if [ -z "$k8s_cluster_url" ]; then
    echo "invalid payload (missing k8s_cluster_url)"
    exit 1
  fi
  if [[ "$k8s_cluster_url" =~ https.* ]]; then

    k8s_cluster_ca=$(jq -r '.source.k8s_cluster_ca // ""' < $payload)
    k8s_admin_key=$(jq -r '.source.k8s_admin_key // ""' < $payload)
    k8s_admin_cert=$(jq -r '.source.k8s_admin_cert // ""' < $payload)
    k8s_token=$(jq -r '.source.k8s_token // ""' < $payload)
    k8s_token_path=$(jq -r '.params.k8s_token_path // ""' < $payload)

    mkdir -p /root/.kube

    ca_path="/root/.kube/ca.pem"
    echo "$k8s_cluster_ca" | base64 -d > $ca_path
    kubectl config set-cluster default --server=$k8s_cluster_url --certificate-authority=$ca_path

    if [ -f "$source/$k8s_token_path" ]; then
      kubectl config set-credentials admin --token=$(cat $source/$k8s_token_path)
    elif [ ! -z "$k8s_token" ]; then
      kubectl config set-credentials admin --token=$k8s_token
    else
      key_path="/root/.kube/key.pem"
      cert_path="/root/.kube/cert.pem"
      echo "$k8s_admin_key" | base64 -d > $key_path
      echo "$k8s_admin_cert" | base64 -d > $cert_path
      kubectl config set-credentials admin --client-certificate=$cert_path --client-key=$key_path
    fi

    kubectl config set-context default --cluster=default --user=admin
  else
    kubectl config set-cluster default --server=$k8s_cluster_url
    kubectl config set-context default --cluster=default
  fi

  kubectl config use-context default
  kubectl version
}

setup_resource() {
  echo "Initializing kubectl..."
  setup_kubernetes $1 $2
}