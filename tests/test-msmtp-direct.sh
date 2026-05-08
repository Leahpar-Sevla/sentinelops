#!/usr/bin/env bash

set -euo pipefail

FROM="${1:-alerts@example.com}"
TO="${2:-recipient@example.com}"
SUBJECT="${3:-[TEST] SentinelOps direct msmtp}"

printf "Subject: %s\nFrom: %s\nTo: %s\n\nDirect msmtp test from %s.\n" \
  "$SUBJECT" "$FROM" "$TO" "$(hostname)" | msmtp -a default "$TO"

echo "Direct msmtp test submitted to: $TO"
echo "Check: journalctl -n 100 | grep -Ei 'smtp|msmtp'"
