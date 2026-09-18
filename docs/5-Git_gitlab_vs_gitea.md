# Introduction

On the last article, I reached a milestone on this project. The Kubernetes cluster was created on the VMs and successfully deployed a simple Nginx pod. Now, I can start working on creating my CICD pipeline and learn how some applications work and re-learn about some applications I had the opportunity to work with before.

For this article I will deploy and compare two git servers, Gitlab and Gitea. Both will be deployed using helm charts. I will compare only their functionality as a git server on this, because both of them have features that I will try out on the next articles, for example CI/CD tools or the registry. I will not make a decision on which will use on my homelab on this article, because I need to compare them with those features against other tools for each component, for example comparing the registry feature of gitlab/gitea against Harbor, or CI features agains Jenkins.

## Why Gitea and Gitlab

There are a lot of git servers available, I could just use Github, but since I am building a homelab, I want to deploy a git server as well. Besides, it is what many companies do to keep all their repositories as private as possible. So I needed to decide between the available options that can be self-hosted and decided to go with Gitea and Gitlab, mainly because both of them are popular options and have good documentation online. Check the first article [1-Architecture_and_hardware (source control options)](1-Architecture_and_hardware.md#source-control-to-store-repositories) for the reasons of each choice, heres the overview: 

 - Gitlab:
   - Very complete package
   - Many features available that I will not use
   - Can do CI/CD
   - Can have registry
   - Heavy on the resources
   
 - Gitea:
   - Can do CI/CD
   - Can have registry
   - Lightweight on resources

## What I will compare on this article

For this article I will deploy and compare both Gitlab and Gitea and see which one fits better for my homelab. For that I will use some metrics and try some operations on both:

 - How simple it is to create a Helm chart
 - How long it takes to deploy and have it ready
 - How much RAM and CPU it uses when Idle
 - CPU and RAM spikes when:
   - Creating ten repositories
   - Pushing ten changes to each repository
   - Pulling the repositories
   - Pushing and pulling a relativly big file (10, 50 and 100MB)
 - Which web UI I like more

# Preparing Reverse Proxy LXC so both git servers are accessible

On a previous article [3-Create and configure LXCs](3-Create_and_conf_LXCs.md#creating-and-configuring-the-reverse-proxy-lxc), I installed and configured a reverse proxy on a LXC container on Proxmox, in order to have a single entry point to all my services. Now I will make use of it. In order to be able to connect to both Gitlab and Gitea, I need to expose them through the reverse proxy.

To do that I created a new Ansible playbook `update-reverse-proxy-config.yaml` on [infrastructure/ansible/playbooks/ of my homelab repository](https://github.com/Joao-Andrade/homelab-devops/tree/v5/infrastructure/ansible/playbooks/update-reverse-proxy-config.yaml). What this playbook does is:

 - Confirms nginx is running on reverse proxy LXC.
 - Updates nginx config to add new paths for Gitlab and Gitea and proxy pass to the cluster.
 - Reload nginx.

From the management-node, with the repository cloned, the playbook can be executed with:

```bash
# cd into infrastructure/ansible/playbooks
ansible-playbook update-reverse-proxy-config.yaml
```

Note that they are only accessible once deployed on the cluster.

The URL to access from the browser are:
 - http://gitlab.internal
 - http://gitea.internal
 
 On the computer that will access from the browser, I needed to edit the `/etc/hosts` file to add the following line:
 
 ```bash
 192.168.1.81	gitlab.internal gitea.internal
 ```

# Deploying Git Servers on my Homelab

On this section I will go through the process of deploying both Gitlab and Gitea on my kubernetes cluster. For each, I will first create the helm charts and then deploy the application.

## Deploying Gitlab

Because Gitlab is a heavy application, there is the possiblility to disable some features in order to reduce the resource usage. On my helm chart, I disabled the following features, because I will not use them on my homelab, at least for now:

- Container Registry
- GitLab Agent Server for Kubernetes
- GitLab Pages
- Reply by email
- Nginx Ingress controller
- CI Runner
- Prometheus
- Toolbox
- Mailroom
- GitLab exporter
- Spamcheck

### Creating Gitlab helm chart

Gitlab has [official documentation](https://docs.gitlab.com/charts/) on how to deploy using Helm.

Because I want to have all resources on [my homelab repository](https://github.com/Joao-Andrade/homelab-devops) and I also want to change the default values of the helm chart, I created a custom helm chart, based on the official one, that disables all features I don't need.

On [infrastructure/helm-charts/source-control/gitlab/](https://github.com/Joao-Andrade/homelab-devops/blob/v5/infrastructure/helm-charts/source-control/gitlab/) there are two files. `Chart.yaml` references the official one and `values.yaml` defines the values I override.

### Deploying Gitlab on the kubernetes cluster

To deploy gitlab on the cluster, on the management-node, with the repository cloned, I used the following command:

```bash
helm install gitlab ./infrastructure/helm-charts/source-control/gitlab --kubeconfig "/root/.kube/homelab_cluster01" --namespace gitlab --create-namespace --wait
```

Until pods were ready it took about 2 minutes.

#### Getting the password

To get the initial password to access gitlab, I runned the following command from the management node:

```bash
kubectl --kubeconfig ~/.kube/homelab_cluster01 -n gitlab get secret gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 --decode; echo
```

#### Accessing Gitlab

Because I already configured the gitlab access on the reverse proxy LXC and updated the `/etc/hosts` file on my computer, I can access gitlab using the following url: [http://gitlab.internal](http://gitlab.internal). Check [prepare reverse proxy LXC section](#preparing-reverse-proxy-lx-so-both-git-servers-are-accessible) on this article on how I did it.

Login with the user root and the password retrieved on the previous step.

![Gitlab Login Page](/images/git/5-gitea-vs-gitlab-01.png)

## Deploying Gitea

Gitea is more lightweight than Gitlab, but even so, it has some services availabe that I don't use, so I can disable them to use even less resources. These services are:

- Postgres
- Valkey

### Creating Gitea helm chart

Similar to gitlab, Gitea has an [offical helm chart](https://gitea.com/gitea/helm-gitea). I created a custom chart based on the offical one and configured the values file to disable some features, namely Postgres and Valkey, and set some values.

On [infrastructure/helm-charts/source-control/gitea/](https://github.com/Joao-Andrade/homelab-devops/blob/v5/infrastructure/helm-charts/source-control/gitea/) there are two files. `Chart.yaml` references the official one and `values.yaml` defines the values I override.

### Deploying Gitea on the kubernetes cluster

To deploy gitea on the cluster, on the management-node, with the repository cloned, I used the following command:

```bash
helm install gitea ./infrastructure/helm-charts/source-control/gitea --kubeconfig "/root/.kube/homelab_cluster01" --namespace gitea --create-namespace --wait
```

To have the pod ready, it took about 40 seconds.

# Comparing Gitlab and Gitea

On this section I will describe all the tests I performed on both git servers. Because I want to test how fast each git server handles some tasks, I decided to create a script to do most of the tests. I could also do them through the Web UI, but I wanted to have some metric to compare and share.

At no time, both servers were running at same time. Either Gitlab or Gitea was running on the cluster.

Before doing any action, other than accessing from browser and logging in to confirm it works, I left both git servers running for 1 hour, in order to let them settle and have a better idea of their resource consumption and efficiency on doing the tasks. It may have no real impact, but that way I think it garantees it is stable and not doing any initialization task.

## Resource consumption baselines

In order to properly evaluate how much RAM and CPU each git server uses, I need to have a baseline. For that, on the management node, I runned the command `kubectl --kubeconfig ~/.kube/config top nodes`. This shows me the resource usage of each node on the cluster. I could check each pod consumption as well, but because any pod can be on any node, I just need to have an overall view of the cluster:

```bash
# kubectl --kubeconfig ~/.kube/config top nodes
NAME       CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
k3s-cp01   52m          2%       1813Mi          46%
k3s-wk01   14m          0%       817Mi           10%
k3s-wk02   11m          0%       803Mi           10%
```

I also checked Proxmox and compared the CPU and RAM before and after, but will only use the kubernetes data for this article, unless the data is not consistent between kubectl and Proxmox.

### Gitlab when Idle

After deploying gitlab, I checked the resource usage again after one hour:

```bash
# kc01 top nodes
NAME       CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
k3s-cp01   58m          2%       1985Mi          50%
k3s-wk01   51m          1%       2426Mi          30%
k3s-wk02   109m         2%       2105Mi          26%
```

As it is possible to see, the cluster consumption increased from 77m CPU and 3433Mi RAM to 218m CPU and 6516Mi RAM, which is about **183%** increase on CPU usage and about **90%** increase on RAM usage.

### Gitea when Idle

After deploying gitea, I checked the resource usage again after one hour:

```bash
# kc01 top nodes
NAME       CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
k3s-cp01   50m          2%       1815Mi          46%
k3s-wk01   20m          0%       937Mi           11%
k3s-wk02   15m          0%       802Mi           10%
```

As it is possible to see, the cluster consumption increased from 77m CPU and 3433Mi RAM to 85m CPU and 3554Mi RAM, which is about **10%** increase on CPU usage and about **3.5%** increase on RAM usage.

## Doing some repository tasks

One way to evaluate which git server may be better is to evaluate how long each one takes to perform some simple tasks. Not that I need it to be as fast as possible, but because I wanted to have some more metrics to compare the two git servers.

The tasks I tried to simulate to understand which git server performs faster were:

- Creating and cloning 10 repositories
- Pushing 10 changes to each repository
- Pushing 3 big files (10mb, 50mb and 100mb) to each repository
- Cloning the repositories again

I could do some more tests, but I think for some simple tests, it may be enough. The code for the script is [here on my homelab repository](https://github.com/Joao-Andrade/homelab-devops/blob/v5/scripts/management-node/git_servers_tests.sh). Note that I executed the scritp from the management node.

## Getting Gitlab and Gitea access tokens

Before I can do any test through a script, I need to generate an access token on both git servers.

For Gitlab, access through a browser ([see previous section about accessing gitlab](#accessing-gitlab)) and go to profile on top right -> Preferences. On the left menu click on Access -> Personal access tokens. Then click on "Add new token" on top right.

![Gitlab Access Token Creation](/images/5-git-servers-1.png)

I created a token with the `read_repository`, `write_repository`, `read_api` and `api` permissions.

The token generated is going to be used on the script.

## Creating and cloning 10 repositories

The time it took to create and clone 10 empty repositories is as follows:

| Task | Gitlab | Gitea |
|---|---|---|
| Create 10 repositories  | 5s | 6s |
| Clone 10 repositories  | 10s | 9s |

Athough there is a difference of a second on each task, I don't think it is significant and will assume both Gitlab and Gitea takes the same tame to create repositories and it takes the same time to clone a repository.

### Pushing 10 changes to each repository

Next I decided to know how long it takes to push a few files for each repository.

For this I tried to create a simple file structure and copy it to each repository:

```bash
tree
├── example-docs
│   ├── doc1.md
│   └── doc2.md
├── example-src
│   ├── main.sh
│   └── utils.sh
├── example-random-files (each repo will have a different number of files with 1mb each)
│   └── random_file_1.bin
│   └── random_file_2.bin
└── README.md
```

The time it took to do that was:

| Gitlab | Gitea |
|---|---|
| 20s | 22s |

### Pulling the repositories

Now that the repos have content inside, let's pull them.
The way I did on the script is that it removes the repo locally by removing the folder, and then git clone again.

| Gitlab | Gitea |
|---|---|
| 15s | 16s |

As it is possible to see there is not much difference from pulling the repo while empty or with some files.

## Pushing and pulling a big file (10 and 50MB)

Another test I wanted to do was checking how long it takes to push some files that may be heavier. Not that every repo needs heavy files, but why not test it out. For this I tried to create 2 big files, each one with 10mb and 50mb and measured how long it takes to push each file to a different repository and also have a repository with all the files.

| Repository | Gitlab | Gitea |
|---|---|---|
| repo 1 (10MB) | 2s | 3s |
| repo 2 (50MB) | 7s | 7s |
| repo 3 (both files) | 8s | 10s |

Then after pushing the file, I deleted the repositories locally and tried to clone them again. To have some comparison how much it affects the pulling time, I also cloned the repositories before pushing the big files.

| Repository | Gitlab before big files | Gitlab after big files | Gitea before big files | Gitea after big files |
|---|---|---|---|---|
| Repo 1 (10MB) | 1s | 2s | 1s | 1s |
| Repo 2 (50MB) | 1s | 4s | 1s | 4s |
| Repo 3 (both files) | 1s | 5s | 1s | 6s |

As it is possible to see on the table, there are not too much difference between both git servers.

## Conclusion

The big difference is about resource usage, and number of pods, secrets and pvc deployed by each git server. Gitea consumes a fraction of what Gitlab consumes and it is a single pod and requires fewer pvc's and other resources on the cluster. Gitlab on the other hand, has it's services and functionalities separated between more pods, secrets and pvc's, which can be good for debugging or simple to decouple the application.

Regarding performance of each git server, both take almost the same time to do the tasks I tried to simulate. Of course it was only me, a single user, doing them, and if it was a big company with lots of users and activity happening on git, maybe the difference would be more noticeable. But, for a homelab or even a small company with few users, I think both git servers are good options with no big differences in performance.

# Cleaning Gitlab or Gitea installations

On this section I will explain how to uninstall Gitlab or Gitea from the cluster, because `helm uninstall` doesn't clean everything. PVC and secrets.

## Cleaning Gitlab

To remove Gitlab and all resources from the cluster, there are a few steps needed:

- First remove the helm chart:
  - `helm uninstall gitlab --kubeconfig ~/.kube/homelab_cluster01 --namespace gitlab --wait`

- Remove remaining resources:
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 get secrets,pvc,configmaps -n gitlab -o name | grep -v 'kube-root-ca.crt$' | while read -r r; do     kubectl --kubeconfig ~/.kube/homelab_cluster01 delete -n gitlab "$r" --wait=false;   done`

- Confirm there is no remaining resources that the helm cannot remove:
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 -n gitlab get secrets,pvc,pv,configMaps --no-headers | awk '{ print $1 }'`

- Remove namespace
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace gitlab`

## Cleaning Gitea

To remove Gitea and it's resources from the cluster, the steps are similar to Gitlab:

- First remove the helm chart:
  - `helm uninstall gitea --kubeconfig ~/.kube/homelab_cluster01 --namespace gitea --wait`

- Remove remaining resources:
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 get secrets,pvc,configmaps -n gitea -o name | grep -v 'kube-root-ca.crt$' | while read -r r; do     kubectl --kubeconfig ~/.kube/homelab_cluster01 delete -n gitea "$r" --wait=false;   done`

- Confirm there is no remaining resources that the helm cannot remove:
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 -n gitea get secrets,pvc,pv,configMaps --no-headers | awk '{ print $1 }'`

- Remove namespace
  - `kubectl --kubeconfig ~/.kube/homelab_cluster01 delete namespace gitea`

# Conclusions

Overall I like using both of them. Gitea is very lightweight and doesn't have all the features that Gitlab offers, but doesn't make it inferior, because what it does, it does pretty well.

I feel the use case for each is different, where Gitlab offers a lot of features and maybe it is very useful for enterprise environments, while Gitea, because it is lightweight, it tries to appeal to users who just want a git server that can run on their own servers without consuming a lot of resources.

Regarding performance on the tests I did, although simple, they perform similarly.

Before deciding if Gitlab or Gitea is better for my homelab, I need to test them with their own registries and CI/CD tools against other tools I want to use in my homelab, like Harbor or Jenkins. That is for future articles, but if you want to check the conclusion of which git server, registry and CI tool I used, check the article [10 - Git server, registry and CI tool: the decision](./10-Git_registry_ci_tool_the_decision.md).

# Next steps

Now that I have a git server, or on this case two, I can move to the next step, which is deploying ArgoCD so I can use it to manage and deploy all the applications from the repositories to the kubernetes cluster. Check the next article [6 - Install ArgoCD](./6-Install_ArgoCD.md).

# Articles

Heres the full list of articles of this series:

 - [1 - Architecture and Hardware](./1-Architecture_and_hardware.md)
 - [2 - Install Proxmox](./2-Install_proxmox.md)
 - [3 - Create and configure LXCs](./3-Create_and_conf_LXCs.md)
 - [4 - Create and configure VMs](./4-Create_and_conf_VMs.md)
 - [5 - Git: Gitlab vs Gitea](./5-Git_gitlab_vs_gitea.md)
