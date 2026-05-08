#!/usr/bin/env bash

set -euo pipefail

DESTINATION="${1:-}"

if [ -z "$DESTINATION" ]; then
  echo "Usage: $0 recipient@example.com"
  exit 1
fi

echo "SentinelOps wrapper test from $(hostname)." | \
  sentinela-email "$DESTINATION" "[TEST] SentinelOps wrapper"

echo "Wrapper test submitted to: $DESTINATION"
echo "Check: journalctl -n 100 | grep -Ei 'smtp|msmtp'"
