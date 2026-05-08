#!/usr/bin/env bash

set -euo pipefail

failures=0

check_command() {
  local name="$1"
  local cmd="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] $name: $cmd found"
  else
    echo "[FAIL] $name: $cmd not found"
    failures=$((failures + 1))
  fi
}

check_file() {
  local path="$1"
  if [ -f "$path" ]; then
    echo "[OK] File exists: $path"
  else
    echo "[FAIL] Missing file: $path"
    failures=$((failures + 1))
  fi
}

check_command "msmtp" msmtp
check_command "sentinela-email" sentinela-email
check_file "/etc/msmtprc"

if groups | grep -qw "sentinela-mail"; then
  echo "[OK] Current user belongs to sentinela-mail"
else
  echo "[WARN] Current user is not in sentinela-mail"
fi

if [ -f /etc/msmtprc ]; then
  perms=$(stat -c '%a %U:%G' /etc/msmtprc)
  echo "[INFO] /etc/msmtprc permissions: $perms"
fi

if journalctl -n 200 | grep -Eiq "smtpstatus=250|msmtp"; then
  echo "[OK] Recent msmtp logs found"
else
  echo "[WARN] No recent msmtp logs found"
fi

if [ "$failures" -gt 0 ]; then
  echo "Phase 01 local check completed with $failures failure(s)."
  exit 1
fi

echo "Phase 01 local check completed."
