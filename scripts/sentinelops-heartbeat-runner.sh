#!/usr/bin/env bash

# ==========================================================
# SentinelOps - Phase 3
# Dead Man's Switch / External Heartbeat Runner
# ==========================================================
#
# Responsibilities:
#   1. Load local SentinelOps configuration.
#   2. Signal START to Healthchecks.io.
#   3. Execute the SentinelOps check script.
#   4. Signal OK or FAIL to Healthchecks.io.
#   5. Write local audit logs.
#
# Security:
#   - Do not hardcode real Healthchecks URLs here.
#   - Store real URLs only in /etc/sentinelops/sentinelops.conf.
#
# Expected config variables:
#   HEALTHCHECKS_URL
#   SENTINELA_SCRIPT
#   HEARTBEAT_LOG
#   CLIENTE
#   ENVIRONMENT
#   HOSTNAME_PADRAO

set -u

CONFIG_FILE="/etc/sentinelops/sentinelops.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') [FAIL] Config not found: $CONFIG_FILE" >&2
  exit 2
fi

# shellcheck source=/etc/sentinelops/sentinelops.conf
source "$CONFIG_FILE"

HEARTBEAT_LOG="${HEARTBEAT_LOG:-/var/log/sentinelops/heartbeat.log}"
CLIENTE="${CLIENTE:-UNKNOWN}"
ENVIRONMENT="${ENVIRONMENT:-unknown}"
HOSTNAME_PADRAO="${HOSTNAME_PADRAO:-$(hostname)}"
SENTINELA_SCRIPT="${SENTINELA_SCRIPT:-/usr/local/bin/sentinelops-check}"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" >> "$HEARTBEAT_LOG"
}

ping_hc() {
  local endpoint="${1:-}"

  if [[ -z "${HEALTHCHECKS_URL:-}" ]]; then
    log "FAIL" "HEALTHCHECKS_URL is empty or not configured."
    return 1
  fi

  curl -fsS -m 10 --retry 5 -o /dev/null "${HEALTHCHECKS_URL}${endpoint}"
}

log "INFO" "Starting heartbeat. Cliente=${CLIENTE} Ambiente=${ENVIRONMENT} Host=${HOSTNAME_PADRAO} Script=${SENTINELA_SCRIPT}"

# START: records that the run began. If execution hangs after this point,
# Healthchecks can report the run as overdue.
ping_hc "/start" || log "WARN" "Failed to send START ping to Healthchecks."

if [[ ! -x "$SENTINELA_SCRIPT" ]]; then
  log "FAIL" "SentinelOps check not found or not executable: $SENTINELA_SCRIPT"
  ping_hc "/fail" || log "WARN" "Failed to send FAIL ping to Healthchecks."
  exit 3
fi

"$SENTINELA_SCRIPT"
EXIT_CODE=$?

if [[ "$EXIT_CODE" -eq 0 ]]; then
  log "OK" "SentinelOps check completed successfully. Exit code=${EXIT_CODE}"
  ping_hc "" || log "WARN" "Failed to send OK ping to Healthchecks."
  exit 0
fi

log "FAIL" "SentinelOps check returned exit code=${EXIT_CODE}. Validate whether this is technical failure or operational severity."
ping_hc "/fail" || log "WARN" "Failed to send FAIL ping to Healthchecks."
exit "$EXIT_CODE"
