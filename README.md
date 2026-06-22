# Cow wisdom web server

## Prerequisites

```
sudo apt install fortune-mod cowsay -y
```

## How to use?

1. Run `./wisecow.sh`
2. Point the browser to server port (default 4499)

## What to expect?
![wisecow](https://github.com/nyrahul/wisecow/assets/9133227/8d6bfde3-4a5a-480e-8d55-3fef60300d98)

# Problem Statement
Deploy the wisecow application as a k8s app

## Requirement
1. Create Dockerfile for the image and corresponding k8s manifest to deploy in k8s env. The wisecow service should be exposed as k8s service.
2. Github action for creating new image when changes are made to this repo
3. [Challenge goal]: Enable secure TLS communication for the wisecow app.

## Expected Artifacts
1. Github repo containing the app with corresponding dockerfile, k8s manifest, any other artifacts needed.
2. Github repo with corresponding github action.
3. Github repo should be kept private and the access should be enabled for following github IDs: nyrahul


# submission

# Wisecow Application - Containerization, Kubernetes Deployment & GitOps CI/CD

## Project Overview

This project demonstrates the containerization and deployment of the Wisecow application on Kubernetes with automated CI/CD and TLS-enabled ingress access.

The application is a Bash-based HTTP server that generates random fortune messages and displays them using cowsay.

The solution includes:

* Docker containerization
* Kubernetes Deployment and Service
* NGINX Ingress Controller
* TLS-secured HTTPS access
* GitHub Actions CI pipeline
* Docker Hub image registry
* Argo CD GitOps deployment

---

## Architecture

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ├── Build Docker Image
    ├── Push Image to Docker Hub
    └── Update deployment.yaml image tag
    │
    ▼
Git Repository Updated
    │
    ▼
Argo CD
    │
    ▼
Kubernetes Cluster
    │
    ├── Deployment (3 Replicas)
    ├── Service
    ├── Ingress
    └── TLS Secret
    │
    ▼
HTTPS Client Request
```

---

## Repository Structure

```text
.
├── Dockerfile
├── wisecow.sh
├── kubernetes
│   ├── deployment.yml
│   ├── service.yml
│   ├── ingress.yml
│   └── tls-secret.yaml
└── .github
    └── workflows
        └── ci-cd.yml
```

---

## Application Overview

The Wisecow application is a Bash-based web server that:

* Uses Netcat (`nc`) to listen for HTTP requests
* Generates random fortune messages
* Displays output using cowsay
* Serves responses on port 4499

---

## Architectural Observation

During testing, rapid concurrent requests occasionally failed because the application relies on a single-threaded Netcat (`nc`) listener and a synchronous named-pipe (`$RSPFILE`) architecture.

The application cannot process multiple requests concurrently within a single process.

---

## DevOps Resolution

Rather than modifying the original application logic, availability and request handling were improved at the infrastructure layer.

The application was deployed using a Kubernetes Deployment with multiple replicas and exposed through a Kubernetes Service.

This approach:

* Improves availability
* Distributes requests across multiple pods
* Handles concurrent traffic more effectively
* Preserves the simplicity of the original application

---

# Dockerization

## Dockerfile Highlights

* Based on `debian:bookworm-slim`
* Runs as a non-root user
* Minimal package installation
* Exposes port `4499`
* Executes the Wisecow application directly

### Build Image

```bash
docker build -t wisecow .
```

### Run Container

```bash
docker run -p 4499:4499 wisecow
```

### Test

```bash
curl localhost:4499
```

---

# Kubernetes Deployment

## Deployment

Features:

* 3 replicas
* Readiness Probe
* Liveness Probe

Apply:

```bash
kubectl apply -f kubernetes/deployment.yml
```

---

## Service

The application is exposed using a Kubernetes Service.

Apply:

```bash
kubectl apply -f kubernetes/service.yml
```

Verify:

```bash
kubectl get svc
```

---

# TLS Configuration

A self-signed TLS certificate was generated for demonstration purposes.

Generate certificate:

```bash
openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout tls.key \
-out tls.crt \
-subj "/CN=wisecow.local/O=wisecow"
```

Generate Kubernetes TLS Secret manifest:

```bash
kubectl create secret tls wisecow-tls \
--cert=tls.crt \
--key=tls.key \
--dry-run=client -o yaml > kubernetes/tls-secret.yaml
```

Apply secret:

```bash
kubectl apply -f kubernetes/tls-secret.yaml
```

> Note: For demonstration purposes, a self-signed certificate is included. In production environments, certificate management should be handled using cert-manager, a cloud certificate authority, or an external secret management solution.

---

# NGINX Ingress

The application is exposed securely through an NGINX Ingress resource.

Apply ingress:

```bash
kubectl apply -f kubernetes/ingress.yml
```

Install NGINX Ingress Controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

Verify:

```bash
kubectl get ingress
```

---

# HTTPS Validation

After deployment:

```bash
curl -vk -H "Host: wisecow.local" https://localhost:<HTTPS_NODEPORT>
```

Expected behavior:

* TLS handshake succeeds
* Request reaches Ingress
* Traffic is forwarded to the Service
* Wisecow returns a cowsay-generated fortune message

---

# CI/CD Pipeline

GitHub Actions automatically performs:

1. Source checkout
2. Docker image build
3. Docker image push to Docker Hub
4. Deployment manifest image update
5. Commit updated manifest back to Git

Pipeline triggers on changes to:

```text
wisecow.sh
Dockerfile
.github/workflows/**
```

---

# GitOps Deployment using Argo CD

Argo CD continuously watches the Git repository.

Workflow:

```text
Code Change
    │
    ▼
GitHub Actions
    │
    ▼
Docker Hub
    │
    ▼
deployment.yml Updated
    │
    ▼
Git Commit
    │
    ▼
Argo CD Sync
    │
    ▼
Kubernetes Deployment Updated
```

Benefits:

* Declarative infrastructure
* Version-controlled deployments
* Automatic synchronization
* Easy rollback capability

---

# Verification Commands

Check pods:

```bash
kubectl get pods
```

Check services:

```bash
kubectl get svc
```

Check ingress:

```bash
kubectl get ingress
```

Check TLS secret:

```bash
kubectl get secret wisecow-tls
```

Check deployment:

```bash
kubectl get deployment
```

---

# Production Considerations

For production deployments:

* Replace self-signed certificates with cert-manager and a trusted CA
* Use external secret management instead of storing secrets in Git
* Implement image vulnerability scanning in CI/CD
* Add monitoring with Prometheus and Grafana
* Configure centralized logging
* Add Horizontal Pod Autoscaler (HPA) when Metrics Server is available

---

# Conclusion

The Wisecow application was successfully:

* Containerized using Docker
* Deployed on Kubernetes
* Exposed through a Kubernetes Service
* Secured using TLS and NGINX Ingress
* Integrated with GitHub Actions CI
* Deployed using a GitOps workflow with Argo CD

This implementation demonstrates containerization, Kubernetes operations, CI/CD automation, GitOps deployment practices, and secure application exposure using HTTPS.
