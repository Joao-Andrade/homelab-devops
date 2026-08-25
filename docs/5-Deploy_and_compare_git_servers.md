# Introduction

On the last article, I reached a milestone on this project. The Kubernetes cluster was created on the VMs and successfully deployed a simple Nginx pod. Now, I can start working on creating my CICD pipeline and learn how some applications work and re-learn about some applications I had the opportunity to work with before.

For this article I will deploy and compare two git servers, Gitlab and Gitea. Both will be deployed using helm charts. I will compare only their functionality as a git server on this, because both of them have features that I will try out on the next articles, for example CI/CD tools or the registry. I will not make a decision on which will use on my homelab on this article, because I need to compare them with those features against other tools for each component, for example comparing the registry feature of gitlab/gitea against Harbor, or CI features agains Jenkins.

## Why Gitea and Gitlab

There are a lot of git servers available, I could just use Github, but since I am building a homelab I want to deploy a git server as well. Besides, it is want many companies do and keep all their repositories as private as possible. So I needed to decide between the available options that can be self-hosted and decided to go with Gitea and Gitlab. Mainly because both of them are popular options and have good documentation online. Check the first article [1-Architecture_and_hardware (source control options)](1-Architecture_and_hardware.md#source-control-to-store-repositories) for the reasons of each choice, heres the overview: 

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
 - How easy it is to upgrade to a newer version
 - How easy it is to backup and restore

# Deploying Git Servers on my Homelab

On this section I will go through the process of deploying both Gitlab and Gitea on my kubernetes cluster. For each, I will first create the helm charts and then deploy the application.

## Deploying Gitlab

Because Gitlab is a heavy application, there is the possiblility to disable some features in order to reduce the resource usage. On my helm chart, I disabled the following features, because I will need them:

- 

### Creating Gitlab helm chart



### Deploying Gitlab on the kubernetes cluster

## Deploying Gitea

### Creating Gitea helm chart

### Deploying Gitea on the kubernetes cluster

# Comparing Gitlab and Gitea