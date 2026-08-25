# Helm charts

Helm charts to deploy applications on the kubernetes cluster.

## Charts

- [`simple-app`](./simple-app) — minimal nginx chart, used as a first test on the kubernetes cluster.

## Useful commands

**Lint**:
 - Used to lint the chart for common mistakes.
 - `helm lint . --kubeconfig ~/.kube/homelab_cluster01`

**Template**:
 - Used to show the final result of a helm chart. It shows the final yaml files after applying the templates and values files.
 - `helm template . --kubeconfig ~/.kube/homelab_cluster01`

**Dry-run**:
 - Simulate installing the helm chart on the cluster, but doesn't actually install. Useful to validate everything before actually installing the chart.
 - `helm install <release-name> . --kubeconfig ~/.kube/homelab_cluster01 --dry-run=client`

**Install**:
 - Installs the helm chart on the cluster.
 - `helm install <release-name> . --kubeconfig ~/.kube/homelab_cluster01`

**Upgrade**:
 - Upgrades the helm chart on the cluster. For example changing te replica count from the default values.
 - `helm upgrade <release-name> . --kubeconfig ~/.kube/homelab_cluster01 --set replicaCount=3`

**List**:
 - List the installed charts on the cluster.
 - `helm list --kubeconfig ~/.kube/homelab_cluster01`

**Uninstall**:
 - Uninstalls the helm chart from the cluster.
 - `helm uninstall <release-name> --kubeconfig ~/.kube/homelab_cluster01`