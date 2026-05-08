# Phase 03 Validation Summary — External Heartbeat

## Summary

Phase 03 adds an external Dead Man's Switch to SentinelOps using Healthchecks.io. The lab implementation validates that SentinelOps can report successful executions, technical failures, and recovery.

This phase is designed to cover the monitoring blind spot where a server cannot send alerts because it is offline, disconnected, or unable to run cron.

## Implemented components

| Component | Status |
|---|---|
| Healthchecks check | Implemented |
| Local secure config variable `HEALTHCHECKS_URL` | Implemented |
| Heartbeat runner | Implemented |
| Local heartbeat log | Implemented |
| Cron output log | Implemented |
| `/start` ping | Implemented |
| success ping | Implemented |
| `/fail` ping | Implemented |
| Cron automation | Implemented and tested temporarily every minute |

## Lab check

```text
SENTINELOPS-TESTE-LAB-HEARTBEAT
```

Healthchecks schedule:

```text
Period: 1 hour
Grace Time: 15 minutes
```

Cron baseline:

```cron
5 * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

## Tests completed

### 1. Healthchecks direct ping

Validated direct communication with Healthchecks:

```text
/start -> OK
success -> OK
```

### 2. Runner manual execution

The runner executed `sentinelops-check` and returned success:

```text
runner_exit=0
```

### 3. Cron execution

Cron was temporarily changed to run every minute for validation. `journalctl -u cron` showed the runner command executing successfully.

### 4. Controlled technical failure

The config was temporarily changed to point to a nonexistent script:

```text
SENTINELA_SCRIPT="/usr/local/bin/sentinelops-check-inexistente"
```

Expected failure occurred:

```text
runner_exit=3
[FAIL] Sentinela não encontrado ou sem permissão de execução
```

### 5. Recovery after failure

The config was restored to:

```text
SENTINELA_SCRIPT="/usr/local/bin/sentinelops-check"
```

The runner returned to success:

```text
runner_exit=0
```

Healthchecks sent both DOWN and UP notifications during the controlled failure/recovery cycle.

## Pending before closing Phase 03

- [ ] Reconfirm cron is back to hourly schedule:

```cron
5 * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

- [ ] Perform missing-ping / silent server test.
- [ ] Restore Healthchecks check to `Period: 1 hour`, `Grace Time: 15 minutes` after any accelerated tests.
- [ ] Remove or rename the default `My First Check` in Healthchecks.
- [ ] Rotate the lab Ping URL before any production reuse.
- [ ] Add logrotate policy for `/var/log/sentinelops/*.log` in a later hardening phase.

## Security notes

- The real `HEALTHCHECKS_URL` must never be committed.
- Repository files must only contain placeholders.
- Each server must have a unique Healthchecks check and unique Ping URL.

## Official references

- Healthchecks.io Pinging API: https://healthchecks.io/docs/http_api/
- Healthchecks.io check configuration: https://healthchecks.io/docs/configuring_checks/
