#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  CI/CD Monitoring Stack — Ubuntu/WSL/Linux Setup Script
#  Jenkins + Prometheus + Grafana
# ═══════════════════════════════════════════════════════════════

set -e  # Exit on any error

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_banner() {
  echo -e "${CYAN}"
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║     CI/CD Monitoring Stack Setup                     ║"
  echo "║     Jenkins + Prometheus + Grafana                   ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

print_step() {
  echo -e "\n${BLUE}▶ $1${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

# ── Check Prerequisites ──────────────────────────────────────
check_prerequisites() {
  print_step "Checking prerequisites..."

  if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    echo "Install Docker: https://docs.docker.com/get-docker/"
    exit 1
  fi
  print_success "Docker found: $(docker --version)"

  if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    print_error "Docker Compose is not installed!"
    exit 1
  fi
  print_success "Docker Compose found"
}

# ── Start Stack ──────────────────────────────────────────────
start_stack() {
  print_step "Starting the monitoring stack..."
  docker compose up -d
  print_success "Stack started!"
}

# ── Wait for Jenkins ─────────────────────────────────────────
wait_for_jenkins() {
  print_step "Waiting for Jenkins to start (this takes ~60 seconds)..."
  local retries=30
  until curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/login | grep -q "200\|403"; do
    echo -n "."
    sleep 5
    retries=$((retries-1))
    if [ $retries -le 0 ]; then
      print_error "Jenkins did not start in time!"
      exit 1
    fi
  done
  echo ""
  print_success "Jenkins is up!"
}

# ── Print Access Info ─────────────────────────────────────────
print_access_info() {
  echo ""
  echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
  echo -e "${GREEN}🎉 Monitoring Stack is RUNNING!${NC}"
  echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "  ${YELLOW}🔧 Jenkins${NC}     → http://localhost:8080"
  echo    "     User: admin | Password: admin123"
  echo ""
  echo -e "  ${YELLOW}📊 Prometheus${NC}  → http://localhost:9090"
  echo ""
  echo -e "  ${YELLOW}📈 Grafana${NC}     → http://localhost:3000"
  echo    "     User: admin | Password: admin123"
  echo ""
  echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
  echo ""
  echo -e "${BLUE}📌 Next Steps:${NC}"
  echo "  1. Open Jenkins → Manage Plugins → Install 'Prometheus Metrics'"
  echo "  2. Open Grafana → Import dashboard from: grafana/dashboards/jenkins-dashboard.json"
  echo "  3. Create a pipeline using jenkins/Jenkinsfile"
  echo "  4. Run the pipeline multiple times to generate metrics"
  echo "  5. View live dashboard in Grafana!"
  echo ""
}

# ── Jenkins Initial Admin Password ───────────────────────────
show_jenkins_password() {
  print_step "Fetching Jenkins initial admin password..."
  sleep 5
  local password=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Not ready yet — run: docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword")
  echo -e "${YELLOW}Jenkins Admin Password: ${password}${NC}"
}

# ── Main ──────────────────────────────────────────────────────
main() {
  print_banner
  check_prerequisites
  start_stack
  wait_for_jenkins
  show_jenkins_password
  print_access_info
}

main "$@"
