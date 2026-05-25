#!/bin/bash

# ─── Colors ───────────────────────────────────────────────
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

NAMESPACE="audit"

# ─── Helper functions ─────────────────────────────────────
info()    { echo -e "${CYAN}  [→]${RESET} $1"; }
section() {
  echo ""
  echo -e "${CYAN}┌─────────────────────────────────────────┐${RESET}"
  echo -e "${CYAN}│  $1${RESET}"
  echo -e "${CYAN}└─────────────────────────────────────────┘${RESET}"
}

header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}║       Audit Notes Service            ║${RESET}"
  echo -e "${CYAN}║             DEBUG                    ║${RESET}"
  echo -e "${CYAN}╚══════════════════════════════════════╝${RESET}"
  echo ""
  echo -e "  Namespace: ${YELLOW}$NAMESPACE${RESET}"
  echo -e "  Time:      $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
}

# ─── Main ─────────────────────────────────────────────────
header

# 1. Pods
section "PODS"
kubectl get pods -n "$NAMESPACE" -o wide

# 2. Services
section "SERVICES"
kubectl get svc -n "$NAMESPACE"

# 3. Endpoints
section "ENDPOINTS"
kubectl get endpoints -n "$NAMESPACE"

# 4. Ingress
section "INGRESS"
kubectl get ingress -n "$NAMESPACE"

# 5. PVC / Storage
section "STORAGE (PVC)"
kubectl get pvc -n "$NAMESPACE"

# 6. Jobs
section "JOBS"
kubectl get jobs -n "$NAMESPACE"

# 7. CronJobs
section "CRONJOBS"
kubectl get cronjobs -n "$NAMESPACE"

# 8. Recent events
section "RECENT EVENTS (last 10)"
kubectl get events -n "$NAMESPACE" \
  --sort-by='.lastTimestamp' \
  | tail -n 10

# 9. Describe pods (solo si hay pods con problemas)
section "POD DETAILS (non-Running)"
PROBLEM_PODS=$(kubectl get pods -n "$NAMESPACE" --no-headers \
  | awk '$3 != "Running" && $3 != "Completed" {print $1}')

if [ -z "$PROBLEM_PODS" ]; then
  echo -e "  ${GREEN}All pods are Running or Completed.${RESET}"
else
  for pod in $PROBLEM_PODS; do
    echo ""
    info "Describing $pod..."
    kubectl describe pod "$pod" -n "$NAMESPACE"
  done
fi

# 10. Logs
section "LOGS (last 20 lines per pod)"
PODS=$(kubectl get pods -n "$NAMESPACE" --no-headers \
  -l app=audit-nodes -o custom-columns=":metadata.name")

if [ -z "$PODS" ]; then
  echo "  No application pods found."
else
  for pod in $PODS; do
    echo ""
    info "Logs from $pod (main-container):"
    kubectl logs "$pod" -n "$NAMESPACE" -c main-container \
      --tail=20 2>/dev/null || echo "  No logs available."
  done
fi

# ─── Footer ───────────────────────────────────────────────
echo ""
echo -e "${CYAN}─────────────────────────────────────────${RESET}"
echo -e "${GREEN}  DEBUG COMPLETE${RESET}"
echo -e "${CYAN}─────────────────────────────────────────${RESET}"
echo ""
