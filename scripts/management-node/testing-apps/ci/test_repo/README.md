# test_repo

Small Python web server (standard library only) used to test the CI pipelines, the
registries and the deployments.

| Endpoint | Response |
|---|---|
| `GET /health` | `{"status": "ok"}` while the server is running |
| `GET /status` | `{"status": "ok", "pod": "<name>"}` (the health plus the pod that answered) |

The name is the hostname: the pod name in Kubernetes, and the container id in Docker.

## Run locally

```bash
python3 app.py
curl http://localhost:8080/health
curl http://localhost:8080/status
```

## Docker

```bash
docker build -t test-repo:1.0 .
docker run --rm -d --name test-repo -p 8080:8080 test-repo:1.0
curl http://localhost:8080/health
curl http://localhost:8080/status
docker stop test-repo
```

## Changing the port

The server listens on port `8080` by default. Set the `PORT` environment variable to change it, **before** starting it.

```bash
# Locally
PORT=9090 python3 app.py

# Docker: set PORT and map the same port
docker run --rm -d --name test-repo -e PORT=9090 -p 9090:9090 test-repo:1.0
```

In Kubernetes, set it in the container spec of the Deployment before applying it, and use the same value in `containerPort` and in the Service `targetPort`:

```yaml
containers:
  - name: test-repo
    image: <registry>/<path>/test-repo:1.0
    env:
      - name: PORT
        value: "9090"
    ports:
      - containerPort: 9090
```

The image has `EXPOSE 8080`, but that is only documentation. The server uses `PORT`, so the container works on the new port without rebuilding.

## Why the image runs as a non-root user

The `Dockerfile` creates an unprivileged user (`app`, uid 10001) and runs the server as that user. If the app is compromised, the attacker doesn't get root inside the container, and clusters that enforce `runAsNonRoot` accept the image. The server uses a port above 1024, so it needs no root rights.

## CI pipelines

The same pipeline (run `hostname` inside an `ubuntu` container as user 1000) for each CI tool:

| CI tool | File |
|---|---|
| Jenkins | `Jenkinsfile` (declarative pipeline with a Kubernetes agent) |
| GitLab CI | `.gitlab-ci.yml` |
| Gitea Actions | `.gitea/workflows/ci.yaml` |

Jenkins' `retries 2` is the `retry: 2` of the GitLab job. Gitea Actions has no job retry. The GitLab output is the pod name (Kubernetes executor), and the Gitea output is the container id (Docker-in-Docker).
