# gitlab-runner

This chart uses as a base the [official GitLab Runner Helm chart](https://docs.gitlab.com/runner/install/kubernetes/) (chart `0.88.0`, to be confirmed, GitLab Runner `18.11`). It uses the Kubernetes executor, so every CI job runs in its own pod, and it connects to the GitLab deployed in this cluster through its internal service.

All the toggles live in [`values.yaml`](./values.yaml).

# Deploy

## Before deploying: create the runner and the Secret

The runner token is not stored in git.

1. On GitLab (`http://gitlab.internal`) go to Admin Area -> CI/CD -> Runners -> `Create instance runner` (or create it on a group or project). Fill the tags (for example `homelab`) and create it.
2. Copy the runner authentication token that starts with `glrt-`. It is shown only once.
3. Create the namespace and the Secret:

```bash
kubectl create namespace gitlab-runner --kubeconfig ~/.kube/homelab_cluster01

kubectl create secret generic gitlab-runner-token -n gitlab-runner --kubeconfig ~/.kube/homelab_cluster01 \
  --from-literal=runner-token=<glrt-token> \
  --from-literal=runner-registration-token=""
```

## Via ArgoCD Application Set

This chart is under the [`infrastructure/helm-charts/argo-deploys/stateless/`](../../) folder, so the `argo-deploys-stateless` ApplicationSet deploys it into the `gitlab-runner` namespace (the namespace is the name of this folder). It is stateless because the runner keeps no data, and the token is in the Secret.

## Manually deploying the helm-chart

```bash
# From inside infrastructure/helm-charts/argo-deploys/stateless/ci/gitlab-runner
helm repo add gitlab https://charts.gitlab.io
helm dependency update
helm install gitlab-runner . --kubeconfig ~/.kube/homelab_cluster01 --namespace gitlab-runner --create-namespace
```

# Using it

After a minute the runner should appear as online on GitLab. To use it, add a `.gitlab-ci.yml` to a repository, for example:

```yaml
hello:
  script:
    - echo "Hello from $(hostname)"
```

Building images (Docker-in-Docker) needs `privileged = true` on the runner configuration in `values.yaml`, which is disabled by default.

# Cleaning up

```bash
# If it was installed manually
helm uninstall gitlab-runner --kubeconfig ~/.kube/homelab_cluster01 --namespace gitlab-runner --wait

# Check what is left and remove the namespace (this also removes the token Secret)
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n gitlab-runner get all,secrets,configMaps
kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace gitlab-runner
```

If it was deployed via ArgoCD, remove the folder from the repository and wait for ArgoCD to sync before the commands above. Then delete the runner on GitLab (Admin Area -> CI/CD -> Runners).
