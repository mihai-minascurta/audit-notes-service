#!/bin/bash

# ─── Colors ───────────────────────────────────────────────
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

NAMESPACE="audit"

# ─── Helper functions ─────────────────────────────────────
ok()   { echo -e "${GREEN}  [✓]${RESET} $1"; }
info() { echo -e "${CYAN}  [→]${RESET} $1"; }
warn() { echo -e "${YELLOW}  [!]${RESET} $1"; }

header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}║       Audit Notes Service            ║${RESET}"
  echo -e "${CYAN}║            CLEANUP                   ║${RESET}"
  echo -e "${CYAN}╚══════════════════════════════════════╝${RESET}"
  echo ""
}

# ─── Confirmare ───────────────────────────────────────────
header

warn "This will delete ALL resources in namespace '$NAMESPACE'."
echo ""
read -p "  Are you sure? (yes/no): " CONFIRM
echo ""

if [ "$CONFIRM" != "yes" ]; then
  echo -e "${YELLOW}  Cleanup cancelled.${RESET}"
  echo ""
  exit 0
fi

# ─── Stergere resurse ─────────────────────────────────────
info "Deleting CronJobs..."
kubectl delete cronjobs --all -n "$NAMESPACE" 2>/dev/null && ok "CronJobs deleted." || ok "No CronJobs found."

info "Deleting Jobs..."
kubectl delete jobs --all -n "$NAMESPACE" 2>/dev/null && ok "Jobs deleted." || ok "No Jobs found."

info "Deleting Deployment..."
kubectl delete deployment --all -n "$NAMESPACE" 2>/dev/null && ok "Deployments deleted." || ok "No Deployments found."

info "Deleting Services..."
kubectl delete svc --all -n "$NAMESPACE" 2>/dev/null && ok "Services deleted." || ok "No Services found."

info "Deleting Ingress..."
kubectl delete ingress --all -n "$NAMESPACE" 2>/dev/null && ok "Ingress deleted." || ok "No Ingress found."

info "Deleting NetworkPolicy..."
kubectl delete networkpolicy --all -n "$NAMESPACE" 2>/dev/null && ok "NetworkPolicies deleted." || ok "No NetworkPolicies found."

info "Deleting ConfigMap..."
kubectl delete configmap --all -n "$NAMESPACE" 2>/dev/null && ok "ConfigMaps deleted." || ok "No ConfigMaps found."

info "Deleting Secrets..."
kubectl delete secret --all -n "$NAMESPACE" 2>/dev/null && ok "Secrets deleted." || ok "No Secrets found."

info "Deleting ServiceAccount..."
kubectl delete serviceaccount --all -n "$NAMESPACE" 2>/dev/null && ok "ServiceAccounts deleted." || ok "No ServiceAccounts found."

info "Deleting Role & RoleBinding..."
kubectl delete role --all -n "$NAMESPACE" 2>/dev/null && ok "Roles deleted." || ok "No Roles found."
kubectl delete rolebinding --all -n "$NAMESPACE" 2>/dev/null && ok "RoleBindings deleted." || ok "No RoleBindings found."

info "Deleting PVC..."
kubectl delete pvc --all -n "$NAMESPACE" 2>/dev/null && ok "PVCs deleted." || ok "No PVCs found."

info "Deleting namespace '$NAMESPACE'..."
kubectl delete namespace "$NAMESPACE" 2>/dev/null && ok "Namespace deleted." || ok "Namespace not found."

# ─── Footer ───────────────────────────────────────────────
echo ""
echo -e "${CYAN}─────────────────────────────────────────${RESET}"
echo -e "${GREEN}  CLEANUP COMPLETE${RESET}"
echo -e "${CYAN}─────────────────────────────────────────${RESET}"
echo ""
