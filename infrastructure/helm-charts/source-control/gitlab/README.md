# gitlab

This chart uses as a base the [official GitLab Helm chart](https://docs.gitlab.com/charts/), (chart `9.11.12`, GitLab `18.11`). It disables some optional services like Container Registry, GitLab Agent Server for Kubernetes, GitLab Pages, Reply by email, Nginx Ingress controller, CI Runner, Prometheus, Toolbox, Mailroom, GitLab exporter and Spamcheck.

All the toggles (what's enabled/disabled) live in [`values.yaml`](./values.yaml), commented.

## First-time setup

Because this chart depends on the official one, fetch it before installing:

```bash
# From inside infrastructure/helm-charts/source-control/gitlab
helm repo add gitlab https://charts.gitlab.io/
helm dependency update
```

## Usage

To deploy, can run the command from `infrastructure/helm-charts/source-control/gitlab/`:

```bash
helm install gitlab . --kubeconfig ~/.kube/homelab_cluster01 --namespace gitlab --create-namespace
```

Check the initial root password with:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 --decode; echo
```

## Cleaning up

To remove Gitlab and all resources from the cluster, there are a few steps needed:

- First remove the helm chart:
  - `helm uninstall gitlab --kubeconfig ~/.kube/homelab_cluster01 --namespace gitlab --wait`

- Remove remaining resources:
  - `kc01 get secrets,pvc,configmaps -n gitlab -o name |   grep -v 'kube-root-ca.crt$' |   while read -r r; do     kc01 delete -n gitlab "$r" --wait=false;   done`

- Confirm there is no remaining resources that the helm cannot remove:
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 -n gitlab get secrets,pvc,pv,configMaps --no-headers | awk '{ print $1 }'`

- Remove namespace
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace gitlab`
