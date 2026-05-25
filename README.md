<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=700&size=28&pause=1000&color=00E5FF&center=true&vCenter=true&width=700&lines=📋+Audit+Notes+Service;Production-grade+Kubernetes+on+local+Kind;Flask+%2B+K8s+%2B+Ingress+%2B+PVC+%2B+RBAC" alt="Header" />
</div>

<br>

<div align="center">
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" height="30">
  &nbsp;
  <img src="https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white" height="30">
  &nbsp;
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" height="30">
  &nbsp;
  <img src="https://img.shields.io/badge/Kind-00E5FF?style=for-the-badge&logo=linux&logoColor=black" height="30">
  &nbsp;
  <img src="https://img.shields.io/badge/NGINX_Ingress-009639?style=for-the-badge&logo=nginx&logoColor=white" height="30">
</div>

<br>

<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&size=14&pause=2000&color=39FF14&center=true&vCenter=true&width=600&lines=Browser+→+audit.local+→+Ingress+→+Service:5050+→+Pod:5555" alt="Flow" />
</div>

---

## 🧠 What's this about?

A small but **production-structured** internal web service for an audit team — built entirely on Kubernetes with Kind locally. The idea was to create something close enough to a real production setup so the structure can be reused in future projects.

The app lets you check if the service is online, write a short note to persistent storage, and read it back later. Notes survive pod restarts, scaling events, and full redeployments. Everything is configured from the outside — no hardcoded values anywhere in the application code.

---

## ⚡ What's inside?

The deployment covers the full Kubernetes stack: a **Flask app** running with 1 replicas, an **initContainer** that prepares the data folder before anything starts, a **sidecar container** that streams logs to stdout, **readiness and liveness probes** so Kubernetes knows when the app is actually healthy, **resource limits** on CPU and memory, a **PersistentVolumeClaim** so notes are never lost, a **ConfigMap** for environment-specific messages, a **Secret** for the audit token (present but never exposed), a **ServiceAccount** with a minimal **Role** (get/list only — no access to secrets), a **NetworkPolicy** that allows traffic only from the ingress-nginx controller, a **Kubernetes Job** to initialize the default note, and a **CronJob** that runs every minute to check if the note exists and write a report to `/data/reports/`.

Access is handled through **Ingress** at `http://audit.local` — no port-forward as a final solution.

---

## 🗂️ Structure

```text
audit-notes-service/
├── image/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── kubernetes/
│   ├── configmap.yaml       # APP_MODE, MESSAGE, DATA_PATH
│   ├── secret.yaml          # API_TOKEN
│   ├── pvc.yaml             # Persistent storage
│   ├── serviceaccount.yaml
│   ├── role.yaml            # get/list pods, services, endpoints
│   ├── biding.yaml
│   ├── deployment.yaml      # replicas, sidecar, initContainer, probes
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── networkpolicy.yaml
│   ├── job.yaml
│   └── cronjob.yaml
└── scripts/
    ├── build.sh
    ├── healthcheck.sh
    ├── debug.sh
    └── cleanup.sh
```

---

## 🛠️ Prerequisites

Before running anything, make sure you have **Docker**, **Kind**, **kubectl**, and **ingress-nginx** installed and ready. Port **80 must be free** on your host machine, and `audit.local` must resolve locally.

**Create the Kind cluster with port 80 mapped:**
```bash
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
EOF
kind create cluster --config kind-config.yaml
```

**Install ingress-nginx and label the node:**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/kind/deploy.yaml
kubectl label node kind-control-plane ingress-ready=true
kubectl wait --namespace ingress-nginx --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller --timeout=90s
```

**Add audit.local to your hosts file:**
```bash
echo "127.0.0.1 audit.local" | sudo tee -a /etc/hosts
```

**Load the Docker image into Kind:**
```bash
kind load docker-image audit-notes-app:1.0 --name kind
```

---

## 🚀 Run it

```bash
./scripts/build.sh        # deploys everything in the correct order
./scripts/healthcheck.sh  # tests all endpoints through audit.local
./scripts/debug.sh        # full system state: pods, logs, events, jobs, storage
./scripts/cleanup.sh      # removes all Kubernetes resources
```

---

## 📸 Screenshots

**Build**
<!-- Add screenshot -->

**Healthcheck**
<!-- Add screenshot -->

**App at http://audit.local**
<!-- Add screenshot -->

**Debug overview**
<!-- Add screenshot -->

**CronJob reports in /data/reports/**
<!-- Add screenshot -->

---

## 🤖 A note on the Bash scripts

The Kubernetes architecture, YAML manifests, and application logic were designed and built manually. The Bash scripts (`build.sh`, `healthcheck.sh`, `debug.sh`, `cleanup.sh`) were developed with **AI assistance** — writing them from scratch would have taken significantly longer and the focus of this project was the Kubernetes layer, not shell scripting.

---

<div align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&size=13&pause=2000&color=BC13FE&center=true&vCenter=true&width=500&lines=namespace:+audit+|+replicas:+1+|+probes:+active+|+pvc:+bound" alt="Footer" />
</div>
