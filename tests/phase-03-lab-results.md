# Phase 3 — Lab Validation Results

## Environment

| Field | Value |
|---|---|
| Server | `dev-server` |
| Environment | `lab` |
| Healthchecks check | `SENTINELOPS-TESTE-LAB-HEARTBEAT` |
| Runner | `/opt/sentinelops/bin/sentinelops-heartbeat-runner.sh` |
| SentinelOps check | `/usr/local/bin/sentinelops-check` |
| Config | `/etc/sentinelops/sentinelops.conf` |
| Heartbeat log | `/var/log/sentinelops/heartbeat.log` |
| Cron output log | `/var/log/sentinelops/heartbeat-cron.log` |

## Completed tests

| Test | Status | Evidence |
|---|---|---|
| Healthchecks check created | Passed | Check created as `SENTINELOPS-TESTE-LAB-HEARTBEAT` |
| Direct `/start` ping | Passed | Command returned `OK` |
| Direct success ping | Passed | Command returned `OK` |
| Manual runner execution | Passed | Runner returned `0` |
| SentinelOps internal check | Passed | Report returned `Status: OK` and `No actionable issues detected` |
| Cron execution | Passed | `journalctl -u cron` showed the runner command executing every minute during temporary test |
| Controlled FAIL | Passed | Runner returned `runner_exit=3` after pointing to nonexistent script |
| Recovery after FAIL | Passed | Config restored and runner returned `runner_exit=0` |
| Healthchecks DOWN/UP notification | Passed | Healthchecks sent DOWN after controlled failure and UP after recovery |

## Key observed log excerpts

```text
2026-05-08 19:43:02 [OK] Sentinela concluído com sucesso técnico. Exit code=0
2026-05-08 19:44:02 [OK] Sentinela concluído com sucesso técnico. Exit code=0
2026-05-08 19:45:02 [OK] Sentinela concluído com sucesso técnico. Exit code=0
```

```text
2026-05-08 19:47:53 [INFO] Iniciando heartbeat. Cliente=TESTE Ambiente=lab Host=dev-server Script=/usr/local/bin/sentinelops-check-inexistente
2026-05-08 19:47:54 [FAIL] Sentinela não encontrado ou sem permissão de execução: /usr/local/bin/sentinelops-check-inexistente
```

```text
2026-05-08 19:48:48 [INFO] Iniciando heartbeat. Cliente=TESTE Ambiente=lab Host=dev-server Script=/usr/local/bin/sentinelops-check
2026-05-08 19:48:48 [OK] Sentinela concluído com sucesso técnico. Exit code=0
```

## Pending tests

| Test | Status | Notes |
|---|---|---|
| Missing ping / silent server | Pending | Simulate cron/server silence and confirm Healthchecks DOWN by timeout |
| Final cron verification after reverting to hourly | Pending | Confirm cron is back to `5 * * * *` and not running every minute |
| Remove or rename default `My First Check` | Pending | Avoid operational noise in the Healthchecks dashboard |
| Rotate exposed lab Ping URL before production reuse | Recommended | The lab URL appeared in screenshots/log context; do not reuse for production |

## Current operational recommendation

Before ending the work session, verify the cron file is not left running every minute:

```bash
sudo cat /etc/cron.d/sentinelops-heartbeat
```

Expected production/lab baseline:

```cron
5 * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```
