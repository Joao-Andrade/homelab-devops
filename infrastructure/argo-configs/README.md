# argo-configs

Raw Kubernetes/ArgoCD manifests used to bootstrap ArgoCD itself - not Helm charts, so they live
here rather than under [`helm-charts/`](../helm-charts).

- [`applicationset-stateful.yaml`](./applicationset-stateful.yaml) — discovers every chart under `helm-charts/argo-deploys/stateful/<category>/<chart-name>/` and deploys it as its own Application. `preserveResourcesOnDeletion: true` - removing a chart's folder won't cascade-delete its live resources/data. Needs to be deleted by hand.
- [`applicationset-stateless.yaml`](./applicationset-stateless.yaml) — same, for `helm-charts/argo-deploys/stateless/<category>/<chart-name>/`. No resource preservation - removing the folder fully tears down whatever it deployed.

Both need to be applied to the cluster once, manually:

```bash
kubectl apply -f applicationset-stateful.yaml -n argocd --kubeconfig ~/.kube/homelab_cluster01
kubectl apply -f applicationset-stateless.yaml -n argocd --kubeconfig ~/.kube/homelab_cluster01
```

After that, adding/removing an app under `helm-charts/argo-deploys/` is the only step needed - see
[`../helm-charts/argo-deploys/README.md`](../helm-charts/argo-deploys/README.md) for the chart-side
conventions.
