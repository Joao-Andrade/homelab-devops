# Helm charts managed by ArgoCD

These helm charts are managed by ArgoCD and the source of truth are the Gitea and Gitlab repositories.

Charts are split into two top-level folders, each discovered by its own `ApplicationSet` (the
`ApplicationSet` manifests themselves live in [`infrastructure/argo-configs/`](../../argo-configs),
not here - this folder only holds the charts):

- [`stateful/`](./stateful) — anything with real data worth protecting (Vault's secrets, a database, Gitea/GitLab repos, etc). Discovered by [`applicationset-stateful.yaml`](../../argo-configs/applicationset-stateful.yaml), which sets `preserveResourcesOnDeletion: true` - deleting a chart's folder removes the Application object from ArgoCD but leaves the deployed resources (and their data) alone, so an accidental git mistake can't cascade into a data wipe. Needs to be deleted by hand from cluster.
- [`stateless/`](./stateless) — anything that can be wiped and redeployed from scratch with nothing lost. Discovered by [`applicationset-stateless.yaml`](../../argo-configs/applicationset-stateless.yaml), with no `preserveResourcesOnDeletion` - deleting the folder fully tears down whatever it deployed.

Both ApplicationSets expect the same layout underneath: `<stateful|stateless>/<category>/<chart-name>/`, each a thin wrapper chart (`Chart.yaml` + `values.yaml`) same as the other charts in this repo.

Adding a new app is just: create that folder with a chart in it, and push - no Application manifest to write by hand. Both ApplicationSets need to be applied to the cluster once:

```bash
kubectl apply -f ../../argo-configs/applicationset-stateful.yaml -n argocd --kubeconfig ~/.kube/homelab_cluster01
kubectl apply -f ../../argo-configs/applicationset-stateless.yaml -n argocd --kubeconfig ~/.kube/homelab_cluster01
```

# Charts

Check [helm-charts root readme file](../README.md) to see the list of charts available.
