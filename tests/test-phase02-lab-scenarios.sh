#!/usr/bin/env bash
set -euo pipefail

SENTINELOPS_CHECK="${SENTINELOPS_CHECK:-/usr/local/bin/sentinelops-check}"

run_expect() {
  local name="$1"
  local expected="$2"
  shift 2

  echo
  echo "== $name =="
  set +e
  "$@"
  local code=$?
  set -e

  echo "exit=$code expected=$expected"
  if [[ "$code" -ne "$expected" ]]; then
    echo "[FAIL] $name expected exit $expected but got $code"
    exit 1
  fi
  echo "[OK] $name"
}

run_expect "Clean state" 0 "$SENTINELOPS_CHECK" --no-email

echo "fallback test $(date)" > /var/lib/sentinelops/backup-fallback/main/fallback-main-test.txt
run_expect "Fallback main warning" 1 "$SENTINELOPS_CHECK" --no-email
rm -f /var/lib/sentinelops/backup-fallback/main/fallback-main-test.txt

Y=$(date -d "yesterday" +%Y)
M=$(date -d "yesterday" +%m)
D=$(date -d "yesterday" +%d-%m-%y)

case "$M" in
  01) MONTH_NAME="01-JANEIRO" ;;
  02) MONTH_NAME="02-FEVEREIRO" ;;
  03) MONTH_NAME="03-MARCO" ;;
  04) MONTH_NAME="04-ABRIL" ;;
  05) MONTH_NAME="05-MAIO" ;;
  06) MONTH_NAME="06-JUNHO" ;;
  07) MONTH_NAME="07-JULHO" ;;
  08) MONTH_NAME="08-AGOSTO" ;;
  09) MONTH_NAME="09-SETEMBRO" ;;
  10) MONTH_NAME="10-OUTUBRO" ;;
  11) MONTH_NAME="11-NOVEMBRO" ;;
  12) MONTH_NAME="12-DEZEMBRO" ;;
esac

SECONDARY="/mnt/so-backup-active/backups/$Y/$MONTH_NAME/$D/secondary"

if [[ -d "$SECONDARY" ]]; then
  mv "$SECONDARY" "$SECONDARY.TESTE-OFF"
  run_expect "Missing secondary critical" 3 "$SENTINELOPS_CHECK" --no-email
  mv "$SECONDARY.TESTE-OFF" "$SECONDARY"
else
  echo "[WARN] Skipping missing secondary test because $SECONDARY was not found."
fi

if findmnt -rn --mountpoint /mnt/so-archive >/dev/null 2>&1; then
  sudo mount -o remount,rw /mnt/so-archive
  run_expect "Archived disk read-write high" 2 "$SENTINELOPS_CHECK" --no-email
  sudo mount -o remount,ro /mnt/so-archive
else
  echo "[WARN] Skipping archive test because /mnt/so-archive is not mounted."
fi

run_expect "Final clean state" 0 "$SENTINELOPS_CHECK" --no-email
echo
echo "[OK] Phase 2 lab scenarios completed."
