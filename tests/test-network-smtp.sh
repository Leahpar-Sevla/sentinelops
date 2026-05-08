#!/usr/bin/env bash

set -euo pipefail

SMTP_HOST="${1:-smtp.example.com}"
SMTP_PORT="${2:-465}"

printf '== SentinelOps SMTP Network Test ==\n'
printf 'Host: %s\n' "$SMTP_HOST"
printf 'Port: %s\n\n' "$SMTP_PORT"

printf '[1/4] Address resolution\n'
getent ahosts "$SMTP_HOST" || true
printf '\n'

printf '[2/4] IPv4 resolution\n'
getent ahostsv4 "$SMTP_HOST" || true
printf '\n'

printf '[3/4] IPv6 resolution\n'
getent ahostsv6 "$SMTP_HOST" || true
printf '\n'

printf '[4/4] TCP connectivity\n'
if timeout 10 bash -c "</dev/tcp/${SMTP_HOST}/${SMTP_PORT}" 2>/dev/null; then
  echo "OK: ${SMTP_HOST}:${SMTP_PORT} is reachable"
else
  echo "FAILED: ${SMTP_HOST}:${SMTP_PORT} is not reachable"
  exit 1
fi
