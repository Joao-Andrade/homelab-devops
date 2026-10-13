# hashicorp-vault

This chart uses as a base the [official HashiCorp Vault Helm chart](https://github.com/hashicorp/vault-helm) (chart `0.34.1`, Vault `v2.0.4`). Runs Vault in standalone mode (single pod, file storage) instead of Raft HA, since I use a single-node cluster. The Agent Injector is disabled by default.

All the toggles live in [`values.yaml`](./values.yaml).

# Deploy

## Via ArgoCD Application Set

This chart is under the [`infrastructure/helm-charts/argo-deploys/stateless/`](../../) folder.

Assuming that there is a ArgoCD ApplicationSet, like it is described on my homelab documentation about [ArgoCD deploy and configuration](../../../../../../docs/6-Deploy_argocd.md#configure-argocd-application-sets), the ArgoCD Application Set `argo-deploy-stateless` will deploy this chart.

## Manually deploying the helm-chart

Because this chart depends on the official one, fetch it before installing:

```bash
# From inside infrastructure/helm-charts/argo-deploys/stateless/secrets-manager/hashicorp-vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm dependency update
```

To deploy the application:

```bash
# From inside infrastructure/helm-charts/argo-deploys/stateless/secrets-manager/hashicorp-vault
helm install vault . --kubeconfig ~/.kube/homelab_cluster01 --namespace hashicorp-vault --create-namespace
```

## Initializing and unsealing (automatic)

Normally Vault starts sealed and requires the initialization and unsealing to be a manual process, but because I am deploying on a homelab, and it is not a production environment on a company, I decided to make the process aumtomatic and make it ready to use right after deployment.

This chart automates the process with a small sidecar container (`auto-unseal`, see `templates/auto-unseal-configmap.yaml`) running inside the same pod. On first boot it runs `vault operator init` itself and stores the unseal keys + root token in a Secret (`hashicorp-vault-unseal-keys`, scoped access via `templates/auto-unseal-rbac.yaml`). If it restarts, it reads that Secret and unseals automatically.

**Security trade-off** - the unseal keys and root token now live
in a Kubernetes Secret in the same cluster Vault is meant to protect secrets for, which is the thing that Vault does not want. If someone uses this, I recommend to store the secret elsewhere and delete the secret.

# Cleaning up

To cleanup Hashicorp Vault, it depends if it was manually installed or deployed via ArgoCD.

Note that deleting the `hashicorp-vault` namespace removes the `hashicorp-vault-unseal-keys` Secret along with it (it lives in that namespace) - that Secret holds the actual unseal keys and root token, so once it's gone, any data in a surviving PV from a previous install becomes permanently unrecoverable (no key material left to unseal it with). Not a concern for a clean teardown, but worth knowing before deleting the namespace if you ever intended to keep the data.

## Via ArgoCD Application Set

If it was deployed via ArgoCD Application Set, then simply remove the folder from the repository and wait for ArgoCD to sync.

Of course, confirm with ArgoCD UI that the application is deleted and verify on the cluster that everything was cleaned up.

From the command line, from a server that has connection. to the cluster:

```bash
# Check if namespace exists
kubectl get namespace --kubeconfig ~/.kube/homelab_cluster01

# Check that all Vault pods are deleted:
kubectl --kubeconfig ~/.kube/homelab_cluster01 get pods -A

# Check other Vault resources:
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n hashicorp-vault get secrets,pvc,pv,configMaps

# Check resources not in the namespace:
kubectl get clusterrole,clusterrolebinding,mutatingwebhookconfiguration,validatingwebhookconfiguration,crd --kubeconfig ~/.kube/homelab_cluster01 | grep -i vault
```

To delete everything related to the namespace:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace hashicorp-vault
```

Then delete whatever resource was found on previous commands.

## Manual installed of the helm-chart

From a command line with access to the cluster:

```bash
helm uninstall vault --kubeconfig ~/.kube/homelab_cluster01 --namespace hashicorp-vault --wait
```

Then verify resources on the cluster:

```bash
# Check if namespace exists
kubectl get namespace --kubeconfig ~/.kube/homelab_cluster01

# Check that all Vault pods are deleted:
kubectl --kubeconfig ~/.kube/homelab_cluster01 get pods -A

# Check other Vault resources:
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n hashicorp-vault get secrets,pvc,pv,configMaps

# Check resources not in the namespace:
kubectl get clusterrole,clusterrolebinding,mutatingwebhookconfiguration,validatingwebhookconfiguration,crd --kubeconfig ~/.kube/homelab_cluster01 | grep -i vault
```

To delete everything related to the namespace:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace hashicorp-vault
```

Then delete whatever resource was found on previous commands.
