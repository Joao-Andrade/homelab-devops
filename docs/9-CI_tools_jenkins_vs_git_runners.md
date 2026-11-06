# Introduction

Now that I have git servers, a secrets manager and an image registry, I can start working on the CI part of my pipeline. In this article I will deploy three CI options and compare them to decide which one suits best my homelab: Jenkins, GitLab Runner (which executes the GitLab CI pipelines) and the Gitea Actions runner (which executes the Gitea Actions workflows).

A CI (Continuous Integration) tool is a very important part of a CI/CD pipeline. Every time someone pushes a change to a repository, it is responsible for at least checking out the code, building it, testing it, creating the container image and pushing it to the registry. Check the first article [1-Architecture_and_hardware (CI options)](./1-Architecture_and_hardware.md#ci-continuous-integration-so-when-a-new-commit-is-done-on-the-repos-the-workflow-runs) for the reasons of each choice, but here is the overview:

 - Jenkins
   - Industry standard, has a lot of plugins and it is very good for CI/CD.
   - Independent of the git server
 - Gitlab CI and GitLab Runner
   - Already part of GitLab, so it integrates well with Gitlab, both the repository and the registry
   - Uses Gitlab Runners to run the jobs
 - Gitea Actions and the Gitea runner
   - Same reason as GitLab, since it already has a registry and a git server, why not use the CI tool as well
   - Workflow and sintax is very similar to Github Actions, so it should be easy to move from Github repos to Gitea repos.

## What I will compare in this article

To compare the three CI tools, I will compare the following:

 - Resource consumption (CPU and memory) when idle
 - How simple it is to write the pipeline for the same simple example
 - How jobs are executed. How many pods does each one create to run the job?
 - Integration with Gitlab, Gitea, and Harbor
 - Create a simple CI pipeline that, from a repository on both Gitea and Gitlab, checkos out the code, builds an image and pushes to the registry, while fetching the credentials from OpenBao 

Whichever CI tool I choose, it will be part of my complete CI/CD pipeline that I will create in the [12 - CI/CD](./12-CICD.md) article.

# Pre-requisites

There are a few actions needed before deploying the CI tools:

 - Preparing the Reverse Proxy LXC (only Jenkins needs it, as the runners have no web UI)
 - Preparing the hosts file
 - Creating the secrets for **TODO** Jenkins And maybe for gitea and gitlab Runners

## Preparing Reverse Proxy LXC so Jenkins is accessible

Like on the previous articles, I need to update the reverse proxy configuration to access the Jenkins web UI. The config is on [infrastructure/ansible/playbooks/update-reverse-proxy-config.yaml of my homelab](https://github.com/Joao-Andrade/homelab-devops/blob/v9/infrastructure/ansible/playbooks/update-reverse-proxy-config.yaml) and the new url will be:

 - http://jenkins.internal

To apply the change to the reverse proxy, I excuted the following command from the `management-node`, with the repository cloned:

```bash
# cd into infrastructure/ansible/playbooks
ansible-playbook update-reverse-proxy-config.yaml
```

## Preparing the hosts file

The computer that will access Jenkins needs the new hostname in its `/etc/hosts` file, if on a Mac or Linux machine. For windows it may be a dfferent method. Appended it to the line that already points to the reverse proxy IP:

```bash
192.168.1.81 jenkins.internal
```

## Creating the secrets for Jenkins

In order to access Jenkins, it is necessary to have some admin account. This can be achieved on two ways. The simple one, that I do not recommend, is setting it on the values file of the Chart, [Jenkins helm chart folder on my repository](https://github.com/Joao-Andrade/homelab-devops/tree/v9/infrastructure/helm-charts/argo-deploys/stateful/ci/jenkins). The values on the values file are:

```bash
jenkins:
  controller:
    admin:
      createSecret: true
      username: "admin"
      # REPLACE the placeholder before deploying
      password: "<set-a-password>"
```

The other option, is to create manually a Kubernetes secret on the cluster, that will contain the credentials. That way, the creentials are not stored on git, even by mistake.

To create the secret, on the management node:

```bash
kubectl create namespace jenkins --kubeconfig ~/.kube/homelab_cluster01
# REPLACE the placeholder before deploying
kubectl create secret generic jenkins-admin -n jenkins --kubeconfig ~/.kube/homelab_cluster01 \
  --from-literal=jenkins-admin-user=admin \
  --from-literal=jenkins-admin-password=<password>
```

On the values file of the [Jenkins helm chart](https://github.com/Joao-Andrade/homelab-devops/tree/v9/infrastructure/helm-charts/argo-deploys/stateful/ci/jenkins/values.yaml), the following need to be set:

```bash
jenkins:
  controller:
    admin:
      createSecret: false
      existingSecret: jenkins-admin
      userKey: jenkins-admin-user
      passwordKey: jenkins-admin-password
```

Then when Jenkins is deployed, it will read from that secret.

# Deploying the CI tools on my Homelab

Like for the previous articles and deployments, I will use ArgoCD to deploy the CI tools, so I just need to copy each folder with the helm chart to the repository that ArgoCD is watching. All the charts are in my [homelab repository](https://github.com/Joao-Andrade/homelab-devops/tree/v9/infrastructure/helm-charts/argo-deploys), under a `ci` category folder, and each one is a wrapper chart around the official one, with a `Chart.yaml` that references it and a `values.yaml` with the values I override.

Jenkins is deployed as a stateful application, because everything that matters is stored in the Jenkins home (jobs, build history, configuration), so I it persistant and  avoid any mistake on git to delete it. The two runners, for Gitea CI and Gitlab CI, are stateless because they do not need to have anything persistant.

## Jenkins

### Creating the Jenkins helm chart

The Jenkins project has an [official helm chart](https://github.com/jenkinsci/helm-charts). My chart on my [homelab repository](https://github.com/Joao-Andrade/homelab-devops/tree/v9/infrastructure/helm-charts/argo-deploys/stateful/ci/jenkins) is based on that and then I override some values. As is, my Helm chart deploys Jenkins without any executors (builds run on Kubernetes agents), the admin credentials can be either from an existing Secret or from variables on values file, it has no TLS, and `http://jenkins.internal` is exposed through the Traefik ingress.

### Deploying Jenkins on the kubernetes cluster

First, I created the namespace and the admin Secret. Check the [Creating the secrets for Jenkins](#creating-the-secrets-for-jenkins) section.

Then copied the [Jenkins folder with the helm chart](https://github.com/Joao-Andrade/homelab-devops/tree/v9/infrastructure/helm-charts/argo-deploys/stateful/ci/jenkins) to the repository that ArgoCD is watching. For my homelab, as it is stateful, I copied it to Gitlab's repository, to `infrastructure/helm-charts/argo-deploys/stateful/ci/jenkins`. ArgoCD will notice the folder and deploy it on the cluster.

Once deployed, confirm the pods are running on the cluster. Jenkins downloads its plugins when it starts, so the first start can take a few minutes:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 get pods -n jenkins
```

### Accessing Jenkins

On the browser, accessed Jenkins thorugh the URL `http://jenkins.internal`. To login I used the credentials created by the secret mentioned on the previous section.

![Jenkins login](./images/9-ci-1.png).





# Next steps

Now that I tested the CI tools, I have all the components to decide which git server, registry and CI tool to use on my homelab. Check the next article [10 - Git server, registry and CI tool: the decision](./10-Git_registry_ci_tool_the_decision.md).

# Articles

Here's the full list of articles of this series:

 - [1 - Architecture and Hardware](./1-Architecture_and_hardware.md)
 - [2 - Install Proxmox](./2-Install_proxmox.md)
 - [3 - Create and configure LXCs](./3-Create_and_conf_LXCs.md)
 - [4 - Create and configure VMs](./4-Create_and_conf_VMs.md)
 - [5 - Git: Gitlab vs Gitea](./5-Git_gitlab_vs_gitea.md)
 - [6 - Deploy ArgoCD](./6-Deploy_argocd.md)
 - [7 - Secrets: Deploy OpenBao](./7-Secrets_openbao.md)
 - [8 - Registry: Harbor vs git registries](./8-Registry_harbor_vs_git_registries.md)
 - [9 - CI tools: Jenkins vs git runners](./9-CI_tools_jenkins_vs_git_runners.md)
 - [10 - Git server, registry and CI tool: the decision](./10-Git_registry_ci_tool_the_decision.md)
 - [11 - Code quality: Sonar, Trivy, Semgrep](./11-Code_quality_sonar_trivy_semgrep.md)
 - [12 - CI/CD](./12-CICD.md)
 - [13 - Observability: Grafana, Prometheus, Loki, Jaeger, SigNoz](./13-Observability_grafana_prometheus_loki_jaeger_sigmoz.md)
 - [14 - Conclusions](./14-Conclusions.md)
