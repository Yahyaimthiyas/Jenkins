# CI/CD Monitoring Integration Project
## Jenkins + Prometheus + Grafana

<div align="center">

![DevOps](https://img.shields.io/badge/DevOps-CI%2FCD%20Monitoring-blue?style=for-the-badge&logo=jenkins)
![Jenkins](https://img.shields.io/badge/Jenkins-LTS-D24939?style=for-the-badge&logo=jenkins)
![Prometheus](https://img.shields.io/badge/Prometheus-Metrics-E6522C?style=for-the-badge&logo=prometheus)
![Grafana](https://img.shields.io/badge/Grafana-Dashboard-F46800?style=for-the-badge&logo=grafana)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker)

</div>

---

## 📋 Project Overview

A complete **CI/CD pipeline monitoring system** that integrates:
- **Jenkins** — runs automated build/test/deploy pipelines
- **Prometheus** — scrapes and stores Jenkins metrics
- **Grafana** — visualizes metrics with real-time dashboards and alerting

> **Tech Stack:** Docker Compose · Jenkins LTS · Prometheus · Grafana · Bash/PowerShell

---

## 🏗️ Architecture

```
Developer
    │
    ▼   Push Code / Trigger Build
┌─────────────┐
│   Jenkins   │  ← CI/CD pipelines (Build/Test/Deploy)
│  :8080      │
└──────┬──────┘
       │  /prometheus endpoint (metrics)
       ▼
┌─────────────┐
│ Prometheus  │  ← Scrapes metrics every 15s
│  :9090      │
└──────┬──────┘
       │  PromQL queries
       ▼
┌─────────────┐
│   Grafana   │  ← Visualizes dashboards & alerts
│  :3000      │
└─────────────┘
```

---

## 📁 Project Structure

```
cicd-monitoring-project/
├── docker-compose.yml              # Orchestrates all services
│
├── jenkins/
│   ├── Jenkinsfile                 # Sample 7-stage CI/CD pipeline
│   └── casc.yaml                  # Jenkins Configuration as Code
│
├── prometheus/
│   ├── prometheus.yml              # Prometheus scrape configuration
│   └── alerts.yml                 # Alerting rules (build fail, slow build, etc.)
│
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── datasource.yml     # Auto-provision Prometheus datasource
│   │   └── dashboards/
│   │       └── dashboard.yml      # Dashboard provider config
│   └── dashboards/
│       └── jenkins-dashboard.json # Pre-built Jenkins monitoring dashboard
│
├── scripts/
│   ├── setup.sh                   # Linux/WSL/Mac one-click setup
│   └── setup.ps1                  # Windows PowerShell one-click setup
│
└── README.md
```

---

## 🚀 Quick Start (Docker — Recommended)

### Prerequisites
- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- Docker Compose v2+
- 4 GB RAM minimum

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/cicd-monitoring-project.git
cd cicd-monitoring-project
```

### 2. Start Everything (One Command)

**Windows (PowerShell):**
```powershell
.\scripts\setup.ps1
```

**Linux / WSL / Mac:**
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

**Or manually:**
```bash
docker compose up -d
```

### 3. Access the Services

| Service | URL | Credentials |
|---------|-----|-------------|
| 🔧 Jenkins | http://localhost:8080 | admin / admin123 |
| 📊 Prometheus | http://localhost:9090 | — |
| 📈 Grafana | http://localhost:3000 | admin / admin123 |

---

## ⚙️ Configuration Steps (First Time)

### Step 1 — Install Jenkins Plugin
1. Open Jenkins → **Manage Jenkins** → **Manage Plugins**
2. Go to **Available** tab → search `Prometheus Metrics`
3. Install and restart Jenkins
4. Verify at: http://localhost:8080/prometheus

### Step 2 — Verify Prometheus Scraping
1. Open Prometheus → http://localhost:9090
2. Go to **Status → Targets**
3. You should see `jenkins` target as **UP** ✅

### Step 3 — View Grafana Dashboard
1. Open Grafana → http://localhost:3000
2. Login with `admin / admin123`
3. Go to **Dashboards → Jenkins** folder
4. Dashboard is **auto-provisioned** — no import needed!

### Step 4 — Create Jenkins Pipeline
1. Jenkins → **New Item** → **Pipeline**
2. Name it `cicd-demo-pipeline`
3. Under Pipeline → Script → paste contents of `jenkins/Jenkinsfile`
4. Save and click **Build Now**
5. Run 5–10 times → watch metrics appear in Grafana!

---

## 📊 Grafana Dashboard Panels

| Panel | Metric | Description |
|-------|--------|-------------|
| **Last Build Result** | `jenkins_builds_last_build_result_ordinal` | SUCCESS/UNSTABLE/FAILED with color |
| **Last Build Duration** | `jenkins_builds_last_build_duration_milliseconds` | Time in seconds |
| **Total Builds** | `jenkins_builds_total` | Count per job |
| **Success Rate** | Calculated from builds | Gauge 0–100% |
| **Duration Over Time** | Time-series | Build time trend graph |
| **Build Count Over Time** | `rate(jenkins_builds_total[5m])` | Build rate graph |
| **Jobs Overview Table** | All jobs | Summary table |

---

## 🔔 Alerting Rules (Prometheus)

| Alert | Condition | Severity |
|-------|-----------|----------|
| `JenkinsBuildFailed` | Last build result == FAILED | 🔴 Critical |
| `JenkinsBuildSlow` | Build duration > 5 minutes | 🟡 Warning |
| `JenkinsNoBuilds` | No builds in 30 min | 🔵 Info |
| `JenkinsDown` | Jenkins unreachable | 🔴 Critical |

View active alerts at: http://localhost:9090/alerts

---

## 🔁 Jenkins Pipeline Stages

The sample `Jenkinsfile` has **7 stages**:

```
Checkout → Build → Unit Tests → Code Quality → 
Docker Build → Integration Tests → Deploy → Smoke Test
```

Each stage has realistic timing (~30 seconds total duration) to generate meaningful metrics.

---

## 🐧 VMware Ubuntu Setup Guide

### Install Ubuntu on VMware Workstation Player
1. Download Ubuntu 22.04 LTS ISO from https://ubuntu.com/download/desktop
2. Create new VM in VMware → 4 GB RAM, 2 CPUs, 40 GB disk
3. Install OpenSSH server during setup

### Install Docker on Ubuntu VM
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
```

### Clone & Run Project
```bash
git clone https://github.com/your-username/cicd-monitoring-project.git
cd cicd-monitoring-project
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Access from Host Machine
Get VM IP:
```bash
ip addr show | grep inet
```
Then access from Windows host:
- Jenkins: `http://<VM-IP>:8080`
- Prometheus: `http://<VM-IP>:9090`
- Grafana: `http://<VM-IP>:3000`

---

## 🛠️ Useful Commands

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View logs
docker compose logs -f jenkins
docker compose logs -f prometheus
docker compose logs -f grafana

# Get Jenkins admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Restart a single service
docker compose restart grafana

# Check service status
docker compose ps

# Remove everything (including volumes)
docker compose down -v
```

---

## 💡 Bonus Features (Implemented)

- ✅ **Auto-provisioned Datasource** — Prometheus connected automatically
- ✅ **Auto-provisioned Dashboard** — No manual import needed
- ✅ **4 Alert Rules** — Build failures, slow builds, downtime
- ✅ **Configuration as Code** — Jenkins configured via YAML (casc.yaml)
- ✅ **One-Click Scripts** — Windows & Linux setup scripts

---

## 📝 Viva Explanation Points

### How Jenkins Exposes Metrics
Jenkins uses the **Prometheus Metrics Plugin** which adds a `/prometheus` endpoint. This endpoint exposes build counts, durations, queue lengths, and job results in Prometheus text format.

### How Prometheus Collects Metrics
Prometheus uses **pull-based scraping** — it fetches the `/prometheus` endpoint from Jenkins every 15 seconds. Metrics are stored in its time-series database (TSDB) for querying via PromQL.

### How Grafana Visualizes
Grafana connects to Prometheus as a datasource and uses **PromQL queries** to fetch metrics. Panels are configured with time-series graphs, stat panels, gauges, and tables. Auto-refresh every 30 seconds provides real-time visibility.

---

## 👨‍💻 Author

| Field | Value |
|-------|-------|
| **Project** | CI/CD Monitoring Integration |
| **Subject** | DevOps |
| **Stack** | Jenkins · Prometheus · Grafana · Docker |
| **Year** | 2024–25 |

---

<div align="center">

Made with ❤️ for DevOps | Jenkins → Prometheus → Grafana

</div>
