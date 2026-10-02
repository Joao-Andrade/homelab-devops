# hashicorp-vault

This chart uses as a base the [official HashiCorp Vault Helm chart](https://github.com/hashicorp/vault-helm)
(chart `0.34.1`, Vault `v2.0.4`). Runs Vault in standalone mode (single pod, file storage) instead of
Raft HA, since this is a single-node cluster. The Agent Injector is disabled by default.

All the toggles live in [`values.yaml`](./values.yaml), commented.

This chart is deployed via the `argo-deploys-stateful` ArgoCD ApplicationSet (see
[`../../../../../argo-configs/applicationset-stateful.yaml`](../../../../../argo-configs/applicationset-stateful.yaml))
- adding/committing this folder is enough, no manual `helm install` needed once that ApplicationSet
is applied to the cluster. The ApplicationSet derives both the Application name and the destination
namespace from this folder's name, so this deploys into the **`hashicorp-vault`** namespace (not
`vault`, not `secrets-manager`).

## First-time setup

Because this chart depends on the official one, fetch it before installing (only needed if
testing locally with `helm install`/`helm template` instead of letting ArgoCD sync it):

```bash
# From inside infrastructure/helm-charts/argo-deploys/stateful/secrets-manager/hashicorp-vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm dependency update
```

## Initializing and unsealing

Unlike the other charts, Vault does **not** come up ready to use after install - it starts
**sealed** and needs to be initialized once. Exec into the pod:

```bash
kubectl exec -it -n hashicorp-vault vault-0 --kubeconfig ~/.kube/homelab_cluster01 -- vault operator init
```

This prints 5 unseal key shares and an initial root token - **save these somewhere safe outside
the cluster**, they're only shown once and there's no way to recover them if lost (Vault is
designed this way on purpose).

Then unseal (needs 3 of the 5 key shares by default, run the command 3 times with 3 different
keys):

```bash
kubectl exec -it -n hashicorp-vault vault-0 --kubeconfig ~/.kube/homelab_cluster01 -- vault operator unseal
```

Vault re-seals itself every time the pod restarts (rescheduled, upgraded, node reboot, etc.), so
this unseal step has to be repeated after any pod restart unless auto-unseal is configured later
(not set up here - out of scope for a homelab single-node setup, but worth knowing about since
you'll hit "sealed" again the first time this pod restarts).

## Usage

To deploy manually (bypassing ArgoCD, e.g. for local testing), run from
`infrastructure/helm-charts/argo-deploys/stateful/secrets-manager/hashicorp-vault/`:

```bash
helm install vault . --kubeconfig ~/.kube/homelab_cluster01 --namespace hashicorp-vault --create-namespace
```
