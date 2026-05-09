#!/usr/bin/env bash

# ==========================================================
# SentinelOps - Phase 3
# Dead Man's Switch / External Heartbeat Runner
# ==========================================================
#
# Responsibilities:
# 1. Load the local SentinelOps configuration.
# 2. Signal START to Healthchecks.io.
# 3. Execute sentinelops-check.
# 4. Send OK to Healthchecks if the monitoring cycle executed.
# 5. Send FAIL to Healthchecks only for technical runner/check failures.
#
# Important rule:
# - sentinelops-check exit code 0 = operational OK.
# - sentinelops-check exit codes 1, 2 or 3 = operational severity detected
#   by SentinelOps. Healthchecks stays OK because the monitoring cycle ran.
# - Missing script, permission error, missing config or unexpected exit code
#   = technical failure and Healthchecks receives FAIL.

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

mkdir -p "$(dirname "$HEARTBEAT_LOG")"

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

ping_hc "/start" || log "WARN" "Failed to send START ping to Healthchecks."

if [[ ! -x "$SENTINELA_SCRIPT" ]]; then
  log "FAIL" "SentinelOps check not found or not executable: $SENTINELA_SCRIPT"
  ping_hc "/fail" || log "WARN" "Failed to send FAIL ping to Healthchecks."
  exit 3
fi

"$SENTINELA_SCRIPT"
EXIT_CODE=$?

case "$EXIT_CODE" in
  0)
    log "OK" "SentinelOps check completed without operational alerts. Exit code=${EXIT_CODE}"
    ping_hc "" || log "WARN" "Failed to send OK ping to Healthchecks."
    exit 0
    ;;

  1|2|3)
    log "OK" "SentinelOps check executed with operational severity. Exit code=${EXIT_CODE}. Heartbeat kept OK."
    ping_hc "" || log "WARN" "Failed to send OK ping to Healthchecks."
    exit 0
    ;;

  *)
    log "FAIL" "SentinelOps check returned unexpected exit code=${EXIT_CODE}"
    ping_hc "/fail" || log "WARN" "Failed to send FAIL ping to Healthchecks."
    exit "$EXIT_CODE"
    ;;
esac
