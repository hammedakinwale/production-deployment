# 🚀 Production-Ready FastAPI Deployment

This project turns a basic FastAPI service into a production-grade deployment using:
- 🐳 Docker (multi-stage and hardened)
- ⚙️ Kubernetes (with best practices)
- 🔁 CI/CD via GitHub Actions
- 📈 Monitoring using Prometheus + Grafana
- 🔐 Security policies and secret management

---

## 🧠 Features Implemented

### ✅ FastAPI Application

```
python
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": "2024-01-01T00:00:00Z"}

@app.get("/items")
async def get_items():
    return {"items": ["item1", "item2", "item3"]}

@app.post("/items")
async def create_item(item: dict):
    return {"message": "Item created", "item": item}
```

### 🐳 Dockerfile
- Multi-stage

- Uses unprivileged user

- replaced some values like the application port with `APIPORT` and container user with `KUBE_USER`

- Image built from root, code in app/

```
# Stage 1: Build
FROM python:3.11-slim as builder
WORKDIR /app

COPY ./app /app
COPY requirements.txt .

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Stage 2: Run
FROM python:3.11-alpine
WORKDIR /app

COPY --from=builder /app /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Drop privileges
RUN adduser -D KUBE_USER
KUBE_USER KUBE_USER

EXPOSE APIPORT

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "APIPORT"]
```

### ⚙️ Kubernetes Deployment

- Deployment: resource limits, liveness/readiness probes, autoscaling (via HPA)

- Secrets/ConfigMap: injected via envFrom

- Service + Ingress: exposes app securely

- RBAC + ServiceAccount

- NetworkPolicy + Pod Security Context

- replaced some values in the manifests like the application/target port with `APIPORT`, port with `PORT`, secrets with `KUBE_SECRET`, and docker image with `IMAGE` with a tool call sed in the pipeline before build and deploy

e.g:

```
image: IMAGE
containerPort: PORT
env:
  - name: APIPORT
    value: "APIPORT"
```

### 🔐 Secrets & Configuration

#### Below secrets are managed through GitHub Actions Secrets:

| Secret Name          | Purpose                |
| -------------------- | ---------------------- |
| `DOCKERHUB_USERNAME` | DockerHub auth         |
| `DOCKERHUB_TOKEN`    | DockerHub auth         |
| `PORT`               | App port (e.g., 8000)  |
| `APIPORT`            | Internal API port      |
| `KUBE_SECRET`        | Kubernetes secret name |
| `KUBECONFIG_DATA`    | base64 kubeconfig      |
| `KUBE_USER`          | container user         |

### 🔁 CI/CD with GitHub Actions

.github/workflows/deploy.yml

#### Steps:

1. Build

    - Validate Python

    - Install deps

2. Lint

    - flake8 app/

3. Push

    - Replace Dockerfile placeholders

    - Build and push Docker image

4. Deploy

    - Patch placeholders (`IMAGE`, `PORT`, `APIPORT`) in all `*.yaml`, `*.json`, `Dockerfile`

    - `kubectl apply -f patched/`

Secrets are injected using sed -i'' into all deployable assets.

### 📈 Monitoring Setup

Prometheus
- Target scraping via prometheus.yml

- Alert rules via alerts.yml

### Grafana
- Pre-configured grafana-dashboard.json

### 🔐 Security Best Practices
- `USER hammed` in Docker

- `networkpolicy.yaml` to restrict traffic

- `pod-security.yaml` (e.g., no privilege escalation)

- `rbac.yaml` for scoped access

- Secrets handled via GitHub + Kubernetes Secrets

### 🛠 Scripts

| Script Name       | Description                    |
| ----------------- | ------------------------------ |
| `deploy.sh`       | Deploys patched manifests      |
| `health-check.sh` | Pings `/health` endpoint       |
| `rollback.sh`     | Rolls back to previous version |

### ✅ Health Check Endpoint

curl http://localhost:8000/health
Returns:` {"status": "healthy", "timestamp": "..."}`

### 🧪 Local Development

```
# Run container locally
docker build -t test-api .
docker run -p 8000:8000 test-api

# Test endpoint
curl http://localhost:8000/items
```

###  RUNBOOK.md – Ops Manual

```
# 🛠 RUNBOOK – Production FastAPI App

## 💥 In Case of Deployment Failure

```bash
cd production-deployment/scripts
./rollback.sh
```

### Terraform Configurations

I included the terraform workload in terraform folder to spin up the kubernetes infrastructure with modular approach but do not include the varible values