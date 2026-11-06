# jenkins

This chart uses as a base the [official Jenkins Helm chart](https://github.com/jenkinsci/helm-charts) (chart `5.9.63`, Jenkins `2.568.3`). The controller has no executors (builds run on Kubernetes agents, one pod per build), the admin credentials come from `values.yaml`, and it is exposed through the Traefik ingress on `http://jenkins.internal` (no TLS).

All the toggles live in [`values.yaml`](./values.yaml).

## Admin credentials

A fixed password is needed because if not set, Jenkins generates a new one everytime it starts and then ArgoCD checks it as a diff. Also from a user perspective, it is not ideal to have the admin password change ocasionally.

Two ways to fix a password for Jenkins are to hardcode the values on the values file or manually create a secret.

### Hardcoded on values file

Another option is that the admin user and password are defined in [`values.yaml`](./values.yaml) under `jenkins.controller.admin`, and the chart creates the Secret itself (`createSecret: true`). Set the password there before deploying (the file has a placeholder). **Important** this stores the password in git.

```bash
createSecret: true
username: admin
password: <password>
```


### Create a kubernetes secret

The other option is to manually create a kubernetes secret, for example `jenkins-admin` with the user and password:


```bash
kubectl create namespace jenkins --kubeconfig ~/.kube/homelab_cluster01
kubectl create secret generic jenkins-admin -n jenkins --kubeconfig ~/.kube/homelab_cluster01 \
  --from-literal=jenkins-admin-user=admin \
  --from-literal=jenkins-admin-password=<password>
```

Then, change the [`values.yaml`](./values.yaml) and under `jenkins.controller.admin` change to something like:

```bash
createSecret: false
existingSecret: jenkins-admin
userKey: jenkins-admin-user
passwordKey: jenkins-admin-password
```

This second option is the better approach, as there is no error in storing credentials on git.

# Deploy

## Via ArgoCD Application Set

This chart is under the [`infrastructure/helm-charts/argo-deploys/stateful/`](../../) folder, so the `argo-deploys-stateful` ApplicationSet deploys it into the `jenkins` namespace (the namespace is the name of this folder). It is stateful because the Jenkins home (jobs, history, configuration) should be on a persistent volume.

## Manually deploying the helm-chart

From the management node, with the repository cloned:

```bash
cd infrastructure/helm-charts/argo-deploys/stateful/ci/jenkins
helm repo add jenkins https://charts.jenkins.io
helm dependency update
helm install jenkins . --kubeconfig ~/.kube/homelab_cluster01 --namespace jenkins --create-namespace
```

# Using it

Login on `http://jenkins.internal` (the hostname needs to be on the reverse proxy configuration and on the `/etc/hosts` of the computer).

The plugins are downloaded when the pod starts, so the first start takes a few minutes and needs internet access.

# Cleaning up

If it was deployed via ArgoCD, remove the folder from the repository and wait for ArgoCD to sync. Because it is stateful, the resources stay on the cluster and need to be removed by hand:

```bash
# Check what is left
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n jenkins get all,secrets,pvc,configMaps
kubectl get clusterrole,clusterrolebinding --kubeconfig ~/.kube/homelab_cluster01 | grep -i jenkins

# Remove everything in the namespace, including the Jenkins home (all jobs and history)
kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace jenkins
```

If it was installed manually, run `helm uninstall jenkins --kubeconfig ~/.kube/homelab_cluster01 --namespace jenkins --wait` first and then check the same resources.
