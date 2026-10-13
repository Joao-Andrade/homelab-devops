# openbao

This chart uses as a base the [official OpenBao Helm chart](https://github.com/openbao/openbao-helm) (chart `0.29.4`, OpenBao `v2.6.2`). Standalone mode (single pod, file storage), AgentInjector disabled by default.

All the toggles live in [`values.yaml`](./values.yaml).

# Deploy

## Via ArgoCD Application Set

This chart is under the [`infrastructure/helm-charts/argo-deploys/stateful/`](../../) folder.

Assuming that there is a ArgoCD ApplicationSet, like it is described on my homelab documentation about [ArgoCD deploy and configuration](../../../../../../docs/6-Deploy_argocd.md#configure-argocd-application-sets), the ArgoCD Application Set `argo-deploys-stateful` will deploy this chart.

## Manually deploying the helm-chart

Because this chart depends on the official one, fetch it before installing:

```bash
# From inside infrastructure/helm-charts/argo-deploys/stateful/secrets-manager/openbao
helm repo add openbao https://openbao.github.io/openbao-helm
helm dependency update
```

To deploy the application:

```bash
# From inside infrastructure/helm-charts/argo-deploys/stateful/secrets-manager/openbao
helm install openbao . --kubeconfig ~/.kube/homelab_cluster01 --namespace openbao --create-namespace
```

## Initializing and unsealing (automatic)

Normally OpenBao starts sealed and requires the initialization and unsealing to be a manual process, but because I am deploying on a homelab, and it is not a production environment on a company, I decided to make the process automatic and make it ready to use right after deployment.

This chart automates the process with a small sidecar container (`auto-unseal`, see `templates/auto-unseal-configmap.yaml`) running inside the same pod. On first boot it initializes OpenBao through its API and stores the unseal keys + root token in a Secret (`openbao-unseal-keys`, scoped access via `templates/auto-unseal-rbac.yaml`). If it restarts, it reads that Secret and unseals automatically.

**Security trade-off** - the unseal keys and root token now live
in a Kubernetes Secret in the same cluster OpenBao is meant to protect secrets for, which defeats part of the purpose of sealing. If someone uses this, I recommend to store the secret elsewhere and delete the secret.

# Cleaning up

To cleanup OpenBao, it depends if it was manually installed or deployed via ArgoCD.

Note that deleting the `openbao` namespace removes the `openbao-unseal-keys` Secret along with it (it lives in that namespace) - that Secret holds the actual unseal keys and root token, so once it's gone, any data in a surviving PV from a previous install becomes permanently unrecoverable (no key material left to unseal it with). Not a concern for a clean teardown, but worth knowing before deleting the namespace if you ever intended to keep the data.

## Via ArgoCD Application Set

If it was deployed via ArgoCD Application Set, then simply remove the folder from the repository and wait for ArgoCD to sync.

Of course, confirm with ArgoCD UI that the application is deleted and verify on the cluster that everything was cleaned up.

From the command line, from a server that has connection. to the cluster:

```bash
# Check if namespace exists
kubectl get namespace --kubeconfig ~/.kube/homelab_cluster01

# Check that all openbao pods are deleted:
kubectl --kubeconfig ~/.kube/homelab_cluster01 get pods -A

# Check other OpenBao resources:
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n openbao get secrets,pvc,pv,configMaps

# Check resources not in the namespace:
kubectl get clusterrole,clusterrolebinding,mutatingwebhookconfiguration,validatingwebhookconfiguration,crd --kubeconfig ~/.kube/homelab_cluster01 | grep -i openbao
```

To delete everything related to the namespace:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace openbao
```

Then delete whatever resource was found on previous commands.

## Manual installed of the helm-chart

From a command line with access to the cluster:

```bash
helm uninstall openbao --kubeconfig ~/.kube/homelab_cluster01 --namespace openbao --wait
```

Then verify resources on the cluster:

```bash
# Check if namespace exists
kubectl get namespace --kubeconfig ~/.kube/homelab_cluster01

# Check that all OpenBao pods are deleted:
kubectl --kubeconfig ~/.kube/homelab_cluster01 get pods -A

# Check other OpenBao resources:
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n openbao get secrets,pvc,pv,configMaps

# Check resources not in the namespace:
kubectl get clusterrole,clusterrolebinding,mutatingwebhookconfiguration,validatingwebhookconfiguration,crd --kubeconfig ~/.kube/homelab_cluster01 | grep -i openbao
```

To delete everything related to the namespace:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace openbao
```

Then delete whatever resource was found on previous commands.
