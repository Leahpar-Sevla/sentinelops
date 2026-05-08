# Phase 03 Lab Results

## Environment

```text
Server: dev-server
Environment: lab
Check: SENTINELOPS-TESTE-LAB-HEARTBEAT
Healthchecks period: 1 hour
Healthchecks grace: 15 minutes
```

## Results

| Test | Result | Evidence |
|---|---|---|
| Direct `/start` ping | PASS | Healthchecks returned OK |
| Direct success ping | PASS | Healthchecks returned OK |
| Runner manual OK | PASS | `runner_exit=0` |
| Cron temporary every-minute execution | PASS | `journalctl -u cron` showed runner command |
| Controlled technical failure | PASS | `runner_exit=3` |
| Healthchecks DOWN notification | PASS | Email received during controlled `/fail` test |
| Recovery after config restore | PASS | `runner_exit=0` and Healthchecks UP notification |
| Missing-ping / silent server | PENDING | To be tested later |

## Notes

The controlled failure test changed:

```text
SENTINELA_SCRIPT="/usr/local/bin/sentinelops-check-inexistente"
```

The runner correctly logged:

```text
[FAIL] SentinelOps check not found or not executable
```

After restoring:

```text
SENTINELA_SCRIPT="/usr/local/bin/sentinelops-check"
```

the runner returned to success.

## Pending work

- Reconfirm cron baseline is restored to hourly.
- Perform missing-ping test.
- Remove or rename the default `My First Check`.
- Rotate lab Healthchecks Ping URL before production reuse.
- Add logrotate policy in a later hardening phase.
