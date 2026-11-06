# gitea-runner

This chart uses as a base the [official Gitea Actions Helm chart](https://gitea.com/gitea/helm-actions) (chart `actions` `0.1.3`, act_runner `3.0.2`). It runs one runner with a Docker-in-Docker sidecar and connects to the Gitea deployed in this cluster through its internal service.

All the toggles live in [`values.yaml`](./values.yaml).

# Deploy

## Before deploying

Gitea needs Actions enabled. This is set in the Gitea chart (`gitea.config.actions.ENABLED: true` on [`values.yaml`](../../../../source-control/gitea/values.yaml)), so Gitea needs to be redeployed with this value (from `infrastructure/helm-charts/source-control/gitea`, run `helm dependency update` and `helm upgrade gitea . --kubeconfig ~/.kube/homelab_cluster01 --namespace gitea`).

The runner registration token is not stored in git:

1. On Gitea (`http://gitea.internal`) go to Site Administration -> Actions -> Runners -> `Create new runner` and copy the registration token (it can also be on an organization or repository).
2. Create the namespace and the Secret:

```bash
kubectl create namespace gitea-runner --kubeconfig ~/.kube/homelab_cluster01

kubectl create secret generic gitea-runner-token -n gitea-runner --kubeconfig ~/.kube/homelab_cluster01 \
  --from-literal=runner-token=<registration-token>
```

## Via ArgoCD Application Set

This chart is under the [`infrastructure/helm-charts/argo-deploys/stateless/`](../../) folder, so the `argo-deploys-stateless` ApplicationSet deploys it into the `gitea-runner` namespace (the namespace is the name of this folder).

## Manually deploying the helm-chart

```bash
# From inside infrastructure/helm-charts/argo-deploys/stateless/ci/gitea-runner
helm repo add gitea-charts https://dl.gitea.com/charts/
helm dependency update
helm install gitea-runner . --kubeconfig ~/.kube/homelab_cluster01 --namespace gitea-runner --create-namespace
```

# Using it

After a minute the runner should appear as online on Gitea. To use it, add a workflow to a repository, for example on `.gitea/workflows/hello.yaml`:

```yaml
name: hello
on: [push]
jobs:
  hello:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Hello from $(hostname)"
```

# Cleaning up

```bash
# If it was installed manually
helm uninstall gitea-runner --kubeconfig ~/.kube/homelab_cluster01 --namespace gitea-runner --wait

# Check what is left (the runner data is on a PVC) and remove the namespace
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n gitea-runner get all,secrets,pvc,configMaps
kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace gitea-runner
```

If it was deployed via ArgoCD, remove the folder from the repository and wait for ArgoCD to sync before the commands above. Then delete the runner on Gitea (Site Administration -> Actions -> Runners).
