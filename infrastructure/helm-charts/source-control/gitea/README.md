# gitea

This chart uses as a base the [official Gitea Helm chart](https://gitea.com/gitea/helm-gitea)
(chart `12.7.0`, Gitea `1.27.0`). It disables the bundled HA PostgreSQL and Valkey-cluster. Instead it uses SQLite database.

All the toggles live in [`values.yaml`](./values.yaml), commented.

## First-time setup

### Before installing

Change `gitea.gitea.admin.password` in `values.yaml` away from the placeholder. It is possible to use `existingSecret` to use a password defined on a kubernetes secret.

Because this chart depends on the official one, from the folder `infrastructure/helm-charts/source-control/gitea/`, fetch it before installing:

```bash
helm repo add gitea-charts https://dl.gitea.com/charts/
helm dependency update
```

## Usage

To deploy, can run the command from `infrastructure/helm-charts/source-control/gitea/`:

```bash
helm install gitea . --kubeconfig ~/.kube/homelab_cluster01 --namespace gitea --create-namespace
```

## Removing Gitea

To remove Gitea and it's resources from the cluster, the steps are:

- First remove the helm chart:
  - `helm uninstall gitea --kubeconfig ~/.kube/homelab_cluster01 --namespace gitea --wait`

- Remove remaining resources:
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 get secrets,pvc,configmaps -n gitea -o name | grep -v 'kube-root-ca.crt$' | while read -r r; do     kubectl --kubeconfig ~/.kube/homelab_cluster01 delete -n gitea "$r" --wait=false;   done`

- Confirm there is no remaining resources that the helm cannot remove:
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 -n gitea get secrets,pvc,pv,configMaps --no-headers | awk '{ print $1 }'`

- Remove namespace
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace gitea`
