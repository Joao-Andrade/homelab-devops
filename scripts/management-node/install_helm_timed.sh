#!/bin/bash

# Variables
APP_NAME="gitea"
CHART_CATEGORY_FOLDER="source-control"
HELM_MODE="install" # install or upgrade

# Normally don't need to change these variables
CHART_NAME="$APP_NAME"
NAMESPACE="$APP_NAME"
CHART_PATH="$HOME/infrastructure/helm-charts/$CHART_CATEGORY_FOLDER/$APP_NAME"
KUBECFG="$HOME/.kube/homelab_cluster01"
EXTRA_ARGS="--create-namespace --wait"

# Time the installation
start_time=`date +%s`

# Update dependencies
echo "helm dependency update --kubeconfig \"$KUBECFG\" \"$CHART_PATH\""
helm dependency update --kubeconfig "$KUBECFG" "$CHART_PATH"

# Install the application
echo "helm $HELM_MODE $CHART_NAME "$CHART_PATH" --kubeconfig \"$KUBECFG\" --namespace $NAMESPACE $EXTRA_ARGS"
helm $HELM_MODE $CHART_NAME "$CHART_PATH" --kubeconfig "$KUBECFG" --namespace $NAMESPACE $EXTRA_ARGS

end_time=`date +%s`

# Calculate the time
time=$((end_time - start_time))

echo "Total time: $time seconds"