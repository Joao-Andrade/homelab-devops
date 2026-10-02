# argocd

This chart uses as a base the [official Argo CD Helm chart](https://github.com/argoproj/argo-helm)
(chart `10.9.2`, Argo CD `v3.5.3`). It disables Dex (SSO) and the notifications controller, and
uses the single-instance Redis instead of the Redis HA subchart, to keep it lightweight.

All the toggles live in [`values.yaml`](./values.yaml), commented.

## First-time setup

### Before installing

Because this chart depends on the official one, from the folder `infrastructure/helm-charts/continuous-deployment/argocd/` fetch it before installing:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm dependency update
```

## Usage

To deploy, can run the command from `infrastructure/helm-charts/continuous-delivery/argocd/`:

```bash
helm install argocd . --kubeconfig ~/.kube/homelab_cluster01 --namespace argocd --create-namespace
```

## Accessing the UI

Argo CD auto-generates an initial admin password on first install and stores it in a secret:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Access through `http://argocd.internal` or through whatever was set up.

After log in, it is possible to change the password and then
delete the `argocd-initial-admin-secret` secret (Argo CD doesn't remove it automatically):

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n argocd delete secret argocd-initial-admin-secret
```

## Cleaning up

To remove ArgoCD and all resources from the cluster, there are a few steps needed:

- First remove the helm chart:
  - `helm uninstall argocd --kubeconfig ~/.kube/homelab_cluster01 --namespace argocd --wait`

- Remove remaining resources:
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 -n argocd get secrets,pvc,configmaps -o name | grep -v 'kube-root-ca.crt$' | while read -r r; do kubectl --kubeconfig ~/.kube/homelab_cluster01 -n argocd delete "$r" --wait=false; done`

- Delete resources with ArgoCD CustomResourceDefinitions
 - `kubectl --kubeconfig ~/.kube/homelab_cluster01 get applications.argoproj.io,appprojects.argoproj.io,applicationsets.argoproj.io -A | while read -r r; do kubectl --kubeconfig ~/.kube/homelab_cluster01 delete "$r" --wait=false -n argocd; done`
 - **If on another namespace, change the `-n argocd` part of the command, or remove the resources manually**.

- Confirm there is no remaining resources that the helm cannot remove:
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 -n argocd get secrets,pvc,pv,configMaps --no-headers'`
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 get applications.argoproj.io,appprojects.argoproj.io,applicationsets.argoproj.io -A`
  - **Delete resources manually if there is something related to argocd**.

- Delete ArgoCD CustomResourceDefinitions
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 delete crd applications.argoproj.io applicationsets.argoproj.io appprojects.argoproj.io`

- Remove namespace
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace argocd`
