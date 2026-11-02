# harbor

This chart uses as a base the [official Harbor Helm chart](https://github.com/goharbor/harbor-helm) (chart `1.19.2`, Harbor `2.15.2`). It runs Harbor with the internal database and Valkey (the Redis replacement, configured under the `redis:` key), exposed through the Traefik ingress on `http://harbor.internal` (no TLS), with the Trivy scanner enabled.

All the toggles live in [`values.yaml`](./values.yaml).

## First-time setup

### Before installing

Because this chart depends on the official one, from the folder `infrastructure/helm-charts/argo-deploys/stateful/registry/harbor/` fetch it before installing:

```bash
helm repo add harbor https://helm.goharbor.io
helm dependency update
```

# Deploy

## About secrets (automatic)

Harbor's chart generates random secrets on every render, which makes ArgoCD see a permanent diff. So all secrets are read from Kubernetes Secrets, which are never stored in git. They are created, with random values, by a `secrets-init` init container that runs in the Valkey pod before it starts (script in `values.yaml` under `redis.internal.initContainers`, RBAC in `templates/secrets-init-rbac.yaml`). Existing secrets are never changed, so it is safe that it runs again when the pod restarts.

The Valkey pod is the one that creates the secrets because it does not read any secret itself (a pod can't start if a secret it mounts doesn't exist yet). The other Harbor pods (core, registry, jobservice) need those secrets, so on the first deploy they stay in `ContainerCreating` until the init container creates them, and then start by themselves.

The init container uses the `alpine/k8s` image. If `openssl`/`htpasswd` are not in it, the script installs them with `apk`, which needs internet access the first time.

The admin password is generated too. To read it (user `admin`):

```bash
kubectl get secret harbor-admin-password -n harbor --kubeconfig ~/.kube/homelab_cluster01 -o jsonpath='{.data.HARBOR_ADMIN_PASSWORD}' | base64 -d
```

**Security trade-off** - same as OpenBao: the secrets live in the same cluster. Fine for a homelab.

### Using fixed secret values

By default every secret is random. To use your own values (for example a known admin password), set them before the first deploy, only applies when the secrets do not exist yet:

```bash
# Recommended: not stored in git. Create the override secret by hand
kubectl create secret generic harbor-secrets-init-overrides -n harbor \
  --from-literal=ADMIN_PASSWORD=<password> --kubeconfig ~/.kube/homelab_cluster01
```

Supported keys: `ADMIN_PASSWORD`, `SECRET_KEY` (16 chars), `CORE_SECRET` (16), `XSRF_KEY` (32), `JOBSERVICE_SECRET` (16), `REGISTRY_SECRET` (16) and `REGISTRY_PASSWORD`. The same keys can be set under `secretsInit` in [`values.yaml`](./values.yaml), but then they are stored in git, so avoid it for anything real. Changing them after Harbor is running is not supported by this setup (for example, Harbor only uses the admin password the first time it initializes its database). To start over with new values, remove the folder, delete the `harbor` namespace and deploy again.

## Via ArgoCD Application Set

This chart is under the [`infrastructure/helm-charts/argo-deploys/stateful/`](../../) folder, so the `argo-deploys-stateful` ApplicationSet deploys it into the `harbor` namespace.

## Manually deploying the helm-chart

```bash
# From inside infrastructure/helm-charts/argo-deploys/stateful/registry/harbor
helm repo add harbor https://helm.goharbor.io
helm dependency update
helm install harbor . --kubeconfig ~/.kube/homelab_cluster01 --namespace harbor --create-namespace
```

# Using it

Login on `http://harbor.internal` with user `admin` and the password from the `harbor-admin-password` secret. Because there is no TLS, docker needs `harbor.internal` in its insecure registries and helm needs `--plain-http`/`--insecure`. Create a project first (for example `library` exists by default), then use `harbor.internal/<project>/<name>:<tag>`.

Trivy downloads its vulnerability database from the internet (`mirror.gcr.io`, `ghcr.io`). Without internet, scans fail unless `trivy.skipUpdate`/`skipJavaDBUpdate` are set and the databases are provided.

# Cleaning up

To cleanup Harbor, it depends if it was manually installed or deployed via ArgoCD.

Note that deleting the `harbor` namespace removes secrets like `harbor-admin-password`, `harbor-secret-key`, `harbor-core-secret`, `harbor-core-xsrf`, `harbor-jobservice-secret`, `harbor-registry-secret` and `harbor-registry-credentials` along with it (they live in that namespace) - not a concern for a clean teardown, but worth knowing before deleting the namespace if you ever intended to keep the data.

## Via ArgoCD Application Set

If it was deployed via ArgoCD Application Set, then simply remove the folder from the repository and wait for ArgoCD to sync.

Of course, confirm with ArgoCD UI that the application is deleted and verify on the cluster that everything was cleaned up.

From the command line, from a server that has connection to the cluster:

```bash
# Check if namespace exists
kubectl get namespace --kubeconfig ~/.kube/homelab_cluster01

# Check that all harbor pods are deleted:
kubectl --kubeconfig ~/.kube/homelab_cluster01 get pods -A

# Check other harbor resources:
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n harbor get secrets,pvc,pv,configMaps

# Check resources not in the namespace:
kubectl get clusterrole,clusterrolebinding,mutatingwebhookconfiguration,validatingwebhookconfiguration,crd --kubeconfig ~/.kube/homelab_cluster01 | grep -i harbor
```

To delete everything related to the namespace:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace harbor
```

Then delete whatever resource was found on previous commands.

## Manual installation of the helm-chart

From a command line with access to the cluster:

```bash
helm uninstall harbor --kubeconfig ~/.kube/homelab_cluster01 --namespace harbor --wait
```

Then verify resources on the cluster:

```bash
# Check if namespace exists
kubectl get namespace --kubeconfig ~/.kube/homelab_cluster01

# Check that all harbor pods are deleted:
kubectl --kubeconfig ~/.kube/homelab_cluster01 get pods -A

# Check other harbor resources:
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n harbor get secrets,pvc,pv,configMaps

# Check resources not in the namespace:
kubectl get clusterrole,clusterrolebinding,mutatingwebhookconfiguration,validatingwebhookconfiguration,crd --kubeconfig ~/.kube/homelab_cluster01 | grep -i harbor
```

To delete everything related to the namespace:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace harbor
```

Then delete whatever resource was found on previous commands.

