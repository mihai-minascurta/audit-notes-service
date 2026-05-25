#!/bin/bash

set -e

# ─── Colors ───────────────────────────────────────────────
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

NAMESPACE="audit"
K8S_DIR="$(dirname "$0")/../kubernetes"

# ─── Helper functions ─────────────────────────────────────
ok()   { echo -e "${GREEN}  [✓]${RESET} $1"; }
info() { echo -e "${CYAN}  [→]${RESET} $1"; }
warn() { echo -e "${YELLOW}  [!]${RESET} $1"; }
fail() { echo -e "${RED}  [✗]${RESET} $1"; exit 1; }

header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}║       Audit Notes Service            ║${RESET}"
  echo -e "${CYAN}║            BUILD                     ║${RESET}"
  echo -e "${CYAN}╚══════════════════════════════════════╝${RESET}"
  echo ""
}

apply() {
  local file="$K8S_DIR/$1"
  if [ -f "$file" ]; then
    kubectl apply -f "$file" > /dev/null
    ok "$1"
  else
    fail "Missing file: $file"
  fi
}

# ─── Main ─────────────────────────────────────────────────
header

# 1. Namespace
info "Creating namespace '$NAMESPACE'..."
if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
  warn "Namespace '$NAMESPACE' already exists, continuing."
else
  kubectl create namespace "$NAMESPACE"
  ok "Namespace '$NAMESPACE' created."
fi

# 2. Base resources
echo ""
info "Applying base resources..."
apply "pvc.yaml"
apply "configmap.yaml"
apply "secret.yaml"

# 3. RBAC
echo ""
info "Applying RBAC..."
apply "serviceaccount.yaml"
apply "role.yaml"
apply "biding.yaml"

# 4. Application
echo ""
info "Applying application..."
apply "deployment.yaml"
apply "service.yaml"
apply "ingress.yaml"
apply "networkpolicy.yaml"

# 5. Jobs
echo ""
info "Applying jobs..."
apply "job.yaml"
apply "cronjob.yaml"

# 6. Wait for deployment
echo ""
info "Waiting for deployment to be ready (max 90s)..."
if kubectl rollout status deployment/main-deployment -n "$NAMESPACE" --timeout=90s; then
  ok "Deployment ready."
else
  fail "Deployment did not start in time. Run ./scripts/debug.sh"
fi

# ─── Final summary ────────────────────────────────────────
echo ""
echo -e "${CYAN}─────────────────────────────────────────${RESET}"
echo -e "${GREEN}  BUILD COMPLETE${RESET}"
echo -e "${CYAN}─────────────────────────────────────────${RESET}"
echo ""
echo -e "  Pods:"; kubectl get pods -n "$NAMESPACE" --no-headers | \
  awk '{printf "    %-40s %s\n", $1, $3}'
echo ""
echo -e "  Access:  ${CYAN}http://audit.local${RESET}"
echo ""
