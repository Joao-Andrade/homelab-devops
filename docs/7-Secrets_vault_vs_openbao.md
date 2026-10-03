# Introduction

Now that I have ArgoCD up and running, I can continue comparing different applications for my homelab. I decided to focus on the secrets management now, namely Hashicorp Vault vs OpenBao.

## Why Hashicorp Vault and OpenBao

I decided on both of them because they are two popular choices for a secrets manager. I already worked with Hashicorp Vault on a previous job, so I know its basics, although I expect to have evolved a lot since then. OpenBao is a fork of Hashicorp Vault, so it should feel familiar and it is open source.Check the first article [1-Architecture_and_hardware (secrets management options)](1-Architecture_and_hardware.md#secrets-to-have-the-secrets-available-to-the-cluster-and-possibly-other-applications) for the reasons of each choice, but here is the overview:

- Hashicorp Vault
   - Lot's of features
   - Some features are hidden behind an enterprise license
   - For basic usage, like storing secrets, doesn't need a paid subscription
   - It is used by a lot of companies
 - OpenBao
   - Fork of Hashicorp Vault
   - Not as complete as Vault yet
   - Clear roadmap on the future features
   - Open source

I could also deploy and compare more choices, like Infiscal, but don't want to compare every tool.

## What I will compare in this article

To compare both tools and decide which I will use on my homelab, I will check the following:

- [Resource consumption when idle](#resource-consumption-when-idle)
- [Ease of use of OpenBao namespaces vs paths on Vault](#ease-of-use-of-openbao-namespaces-vs-paths-on-vault)
- [Integration with other applications](#integration-with-other-applications)

# Preparing Reverse Proxy LXC so both secret managers are accessible

Like for the previous sections, I need to update the reverse proxy configuration so it allows access to the web UIs of Hashicorp Vault and OpenBao. The config will be added to [infrastructure/ansible/playbooks/update-reverse-proxy-config.yaml of my homelab](https://github.com/Joao-Andrade/homelab-devops/blob/v7/infrastructure/ansible/playbooks/update-reverse-proxy-config.yaml) and the new urls will be:
 - http://vault.internal
 - http://openbao.internal

To do that I used the following command from the `management-node`, with the repository cloned:

```bash
# cd into infrastructure/ansible/playbooks
ansible-playbook update-reverse-proxy-config.yaml
```

# Deploying secret managers on my Homelab

## Creating Hashicorp Vault helm chart

## Deploying Hashicorp Vault on the kubernetes cluster

## Accessing Hashicorp Vault

## Creating OpenBao helm Chart

## Deploying OpenBao on the kubernetes cluster

## Accessing OpenBao

# Comparing Hashicorp Vault and OpenBao

## Resource consumption when idle

## Ease of use of OpenBao namespaces vs paths on Vault

## Integration with other applications

### Cluster consumption baseline

In order to properly evaluate how much RAM and CPU each secret manager uses, I need to have a baseline. For that, on the management node, I ran the command `kubectl --kubeconfig ~/.kube/homelab_cluster01 top nodes`. This shows me the resource usage of each node on the cluster. I could check each pod consumption as well, but because any pod can be on any node, I just need to have an overall view of the cluster:

```bash
# kubectl --kubeconfig ~/.kube/homelab_cluster01 top nodes
NAME       CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
k3s-cp01   52m          2%       1813Mi          46%
k3s-wk01   14m          0%       817Mi           10%
k3s-wk02   11m          0%       803Mi           10%
```

### Hashicorp Vault when Idle

After deploying hashicorp vault, I checked the resource usage after one hour:

```bash
# kc01 top nodes
NAME       CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
k3s-cp01   58m          2%       1985Mi          50%
k3s-wk01   51m          1%       2426Mi          30%
k3s-wk02   109m         2%       2105Mi          26%
```

As it is possible to see, the cluster consumption increased from 77m CPU and 3433Mi RAM to 218m CPU and 6516Mi RAM, which is about **183%** increase on CPU usage and about **90%** increase on RAM usage.

### OpenBao when Idle

After deploying OpenBao, I checked the resource usage after one hour:

```bash
# kc01 top nodes
NAME       CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
k3s-cp01   50m          2%       1815Mi          46%
k3s-wk01   20m          0%       937Mi           11%
k3s-wk02   15m          0%       802Mi           10%
```

As it is possible to see, the cluster consumption increased from 77m CPU and 3433Mi RAM to 85m CPU and 3554Mi RAM, which is about **10%** increase on CPU usage and about **3.5%** increase on RAM usage.

## Conclusion

# Cleaning up Hashicorp Vault or OpenBao installations

In this section I will explain how to uninstall Hashicorp Vault or OpenBao from the cluster.

# Next steps

Now that I have a secrets manager, I can move to the next step, which is deploying an image registry so I can create and store Docker images. I will compare Harbor against the registries available on Gitea and Gitlab. Check the next article [8 - Registry: Harbor vs git registries](./8-Registry_harbor_vs_git_registries.md).

# Articles

Here's the full list of articles of this series:

 - [1 - Architecture and Hardware](./1-Architecture_and_hardware.md)
 - [2 - Install Proxmox](./2-Install_proxmox.md)
 - [3 - Create and configure LXCs](./3-Create_and_conf_LXCs.md)
 - [4 - Create and configure VMs](./4-Create_and_conf_VMs.md)
 - [5 - Git: Gitlab vs Gitea](./5-Git_gitlab_vs_gitea.md)
 - [6 - Deploy ArgoCD](./6-Deploy_argocd.md)
 - [7 - Secrets: Vault vs OpenBao](./7-Secrets_vault_vs_openbao.md)
 - [8 - Registry: Harbor vs git registries](./8-Registry_harbor_vs_git_registries.md)
 - [9 - CI tools: Jenkins vs git runners](./9-CI_tools_jenkins_vs_git_runners.md)
 - [10 - Git server, registry and CI tool: the decision](./10-Git_registry_ci_tool_the_decision.md)
 - [11 - Code quality: Sonar, Trivy, Semgrep](./11-Code_quality_sonar_trivy_semgrep.md)
 - [12 - CI/CD](./12-CICD.md)
 - [13 - Observability: Grafana, Prometheus, Loki, Jaeger, SigNoz](./13-Observability_grafana_prometheus_loki_jaeger_sigmoz.md)
 - [14 - Conclusions](./14-Conclusions.md)
