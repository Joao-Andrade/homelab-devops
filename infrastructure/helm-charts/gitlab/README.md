# gitlab

Thin wrapper chart around the official [GitLab Helm chart](https://docs.gitlab.com/charts/), pinned
to chart version `9.11.12` (GitLab 18.11) - the last chart line that still bundles PostgreSQL,
Redis and MinIO as optional subcharts. GitLab 19.0 / chart 10.0 removed those bundled options in
favour of mandatory external services, which doesn't fit a simple homelab install, so this chart
deliberately stays one line behind current.

All the toggles (what's enabled/disabled) live in [`values.yaml`](./values.yaml), commented, instead
of being buried inside the official chart's own defaults.

## First-time setup

Because this chart depends on the official one, fetch it once before linting/installing:

```bash
# From inside infrastructure/helm-charts/gitlab
helm repo add gitlab https://charts.gitlab.io/
helm dependency update
```

This downloads the pinned chart version into a local `charts/` folder (not committed to git -
regenerate it with the command above after cloning).

## Resource sizing note

GitLab is heavy even with everything optional disabled: webservice, sidekiq, gitaly, gitlab-shell,
registry, toolbox, plus the bundled PostgreSQL, Redis and MinIO all run as separate pods. GitLab's
own [minimum requirements](https://docs.gitlab.com/install/requirements/) exceed this cluster's
current capacity (`cp01` 2c/4GB + `wk01`/`wk02` 4c/8GB each), so expect to watch for `Pending`
pods and tune `resources:` requests down further, or free up capacity, before it comes up cleanly.

## Usage

Same commands as [`simple-app`](../simple-app) (see the [top-level README](../README.md)), but
installed into its own `gitlab` namespace rather than `default` - add `--namespace gitlab
--create-namespace` to lint/template/install/upgrade/uninstall commands, e.g.:

```bash
helm install gitlab . --kubeconfig ~/.kube/homelab_cluster01 --namespace gitlab --create-namespace
```

`--create-namespace` only matters for `install` (it creates the namespace if missing); once it
exists, plain `--namespace gitlab` is enough for `upgrade`/`uninstall`/`template`. Remember to add
`--namespace gitlab` to `kubectl get pods`/`port-forward` too, since they otherwise default to
`default`.

No Ingress is wired up yet, so reach GitLab the same way as `simple-app`: `kubectl port-forward`.
