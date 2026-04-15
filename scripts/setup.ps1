# ═══════════════════════════════════════════════════════════════
#  CI/CD Monitoring Stack — Windows PowerShell Setup Script
#  Jenkins + Prometheus + Grafana
# ═══════════════════════════════════════════════════════════════

function Write-Banner {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     CI/CD Monitoring Stack Setup                     ║" -ForegroundColor Cyan
    Write-Host "║     Jenkins + Prometheus + Grafana                   ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step($msg) {
    Write-Host "`n▶ $msg" -ForegroundColor Blue
}

function Write-Success($msg) {
    Write-Host "✅ $msg" -ForegroundColor Green
}

function Write-Warning($msg) {
    Write-Host "⚠️  $msg" -ForegroundColor Yellow
}

function Write-Err($msg) {
    Write-Host "❌ $msg" -ForegroundColor Red
}

# ── Check Docker ──────────────────────────────────────────────
function Check-Docker {
    Write-Step "Checking Docker Desktop..."
    try {
        $version = docker --version
        Write-Success "Docker found: $version"
    } catch {
        Write-Err "Docker is NOT installed or not running!"
        Write-Host "Download Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
        exit 1
    }
}

# ── Start Stack ──────────────────────────────────────────────
function Start-Stack {
    Write-Step "Starting the monitoring stack with Docker Compose..."
    docker compose up -d
    if ($LASTEXITCODE -ne 0) {
        Write-Err "Failed to start Docker Compose!"
        exit 1
    }
    Write-Success "Stack started!"
}

# ── Wait for Jenkins ─────────────────────────────────────────
function Wait-ForJenkins {
    Write-Step "Waiting for Jenkins to be ready (up to 90 seconds)..."
    $retries = 18
    do {
        Start-Sleep -Seconds 5
        Write-Host -NoNewline "."
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080/login" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 403) {
                Write-Host ""
                Write-Success "Jenkins is UP!"
                return
            }
        } catch {}
        $retries--
    } while ($retries -gt 0)
    Write-Err "Jenkins didn't start in time. Check: docker logs jenkins"
}

# ── Get Jenkins Initial Password ──────────────────────────────
function Get-JenkinsPassword {
    Write-Step "Fetching Jenkins admin password..."
    Start-Sleep -Seconds 3
    try {
        $password = docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>$null
        Write-Host "`nJenkins Initial Password: $password" -ForegroundColor Yellow
    } catch {
        Write-Warning "Password not ready yet. Run: docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
    }
}

# ── Print Access Info ─────────────────────────────────────────
function Print-AccessInfo {
    Write-Host ""
    Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🎉 Monitoring Stack is RUNNING!" -ForegroundColor Green
    Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  🔧 Jenkins    → http://localhost:8080" -ForegroundColor Yellow
    Write-Host "     User: admin | Password: admin123"
    Write-Host ""
    Write-Host "  📊 Prometheus → http://localhost:9090" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  📈 Grafana    → http://localhost:3000" -ForegroundColor Yellow
    Write-Host "     User: admin | Password: admin123"
    Write-Host ""
    Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📌 Next Steps:" -ForegroundColor Blue
    Write-Host "  1. Jenkins → Manage Plugins → Install 'Prometheus Metrics Plugin'"
    Write-Host "  2. Grafana → Import dashboard from grafana/dashboards/jenkins-dashboard.json"
    Write-Host "  3. Create a Jenkins Pipeline using jenkins/Jenkinsfile"
    Write-Host "  4. Run pipeline multiple times → watch metrics flow into Grafana!"
    Write-Host ""
}

# ── Main ──────────────────────────────────────────────────────
Write-Banner
Check-Docker
Start-Stack
Wait-ForJenkins
Get-JenkinsPassword
Print-AccessInfo
