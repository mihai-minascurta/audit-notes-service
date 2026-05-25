#!/bin/bash

set -e

# ─── Colors ───────────────────────────────────────────────
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

BASE_URL="http://audit.local"
PASS=0
FAIL=0

# ─── Helper functions ─────────────────────────────────────
ok()   { echo -e "${GREEN}  [✓]${RESET} $1"; }
fail() { echo -e "${RED}  [✗]${RESET} $1"; }
info() { echo -e "${CYAN}  [→]${RESET} $1"; }

header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}║       Audit Notes Service            ║${RESET}"
  echo -e "${CYAN}║          HEALTHCHECK                 ║${RESET}"
  echo -e "${CYAN}╚══════════════════════════════════════╝${RESET}"
  echo ""
}

check() {
  local description="$1"
  local method="$2"
  local endpoint="$3"
  local expected_code="$4"
  local data="$5"

  if [ "$method" = "POST" ] && [ -n "$data" ]; then
    actual_code=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST "$BASE_URL$endpoint" \
      -H "Content-Type: application/json" \
      -d "$data" \
      --max-time 5 2>/dev/null || echo "000")
  else
    actual_code=$(curl -s -o /dev/null -w "%{http_code}" \
      -X "$method" "$BASE_URL$endpoint" \
      --max-time 5 2>/dev/null || echo "000")
  fi

  if [ "$actual_code" = "$expected_code" ]; then
    ok "[$method] $endpoint → $actual_code (expected $expected_code) — $description"
    PASS=$((PASS + 1))
  else
    fail "[$method] $endpoint → $actual_code (expected $expected_code) — $description"
    FAIL=$((FAIL + 1))
  fi
}

# ─── Main ─────────────────────────────────────────────────
header

info "Target: $BASE_URL"
info "Checking connectivity to audit.local..."
echo ""

# Verifică că host-ul e accesibil înainte de teste
if ! curl -s --max-time 5 "$BASE_URL" > /dev/null 2>&1; then
  echo -e "${RED}  [✗] Cannot reach $BASE_URL${RESET}"
  echo -e "${YELLOW}      Make sure audit.local is in /etc/hosts and Ingress is running.${RESET}"
  echo ""
  exit 1
fi

echo ""
info "Running endpoint checks..."
echo ""

# ─── Endpoint checks ──────────────────────────────────────
check "Main page"         GET  "/"       200
check "Health endpoint"   GET  "/health" 200
check "Write note to PVC" GET  "/write"  200
check "Read note from PVC" GET "/read"   200
check "Secret token check" GET "/secret-check" 200
check "Config endpoint"   GET  "/config" 200
check "Logs endpoint"     GET  "/logs"   200

# ─── Summary ──────────────────────────────────────────────
echo ""
echo -e "${CYAN}─────────────────────────────────────────${RESET}"
TOTAL=$((PASS + FAIL))
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}  ALL CHECKS PASSED ($PASS/$TOTAL)${RESET}"
else
  echo -e "${RED}  $FAIL/$TOTAL CHECKS FAILED${RESET}"
fi
echo -e "${CYAN}─────────────────────────────────────────${RESET}"
echo ""

[ "$FAIL" -eq 0 ]
