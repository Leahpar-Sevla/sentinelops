# Phase 03 Lab Results

## Environment

```text
Server: dev-server
Environment: lab
Check: SENTINELOPS-TESTE-LAB-HEARTBEAT
Baseline Healthchecks period: 1 hour
Baseline Healthchecks grace: 15 minutes
```

## Results

| Test | Result | Evidence |
|---|---|---|
| Direct `/start` ping | PASS | Healthchecks returned OK |
| Direct success ping | PASS | Healthchecks returned OK |
| Runner manual OK | PASS | `runner_exit=0` |
| Cron temporary every-minute execution | PASS | `journalctl -u cron` showed runner command |
| Controlled technical failure | PASS | `runner_exit=3` |
| Healthchecks DOWN notification from technical failure | PASS | Email received |
| Recovery after config restore | PASS | `runner_exit=0` and Healthchecks UP notification |
| Operational severity with heartbeat OK | PASS | `sentinelops-check` returned `3`, runner returned `0` |
| Missing-ping / silent heartbeat | PASS | Heartbeat cron disabled, Healthchecks detected silence |
| Recovery after restoring cron | PASS | Healthchecks returned UP |
| Cron restored to hourly baseline | PASS | `5 * * * *` active in `/etc/cron.d/sentinelops-heartbeat` |

## Key validation

The runner was updated to separate operational severity from heartbeat health.

Observed condition:

```text
SentinelOps Check Report
Status: CRITICAL
Expected backup folder missing: 08-05-26
```

Expected runner behavior:

```text
runner_exit=0
[OK] SentinelOps check executed with operational severity. Exit code=3. Heartbeat kept OK.
```

This proves the external heartbeat is measuring whether the monitoring cycle executed, not whether the backup is healthy.
