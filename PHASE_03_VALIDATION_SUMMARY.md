# Phase 03 Validation Summary — External Heartbeat

## Summary

Phase 03 adds an external Dead Man's Switch to SentinelOps using Healthchecks.io. The lab implementation validates successful executions, technical failures, missing pings, operational severity mapping, and recovery.

## Final Phase 03 status

```text
[OK] Check created in Healthchecks
[OK] Direct /start ping tested
[OK] Direct success ping tested
[OK] Runner manual execution tested
[OK] Cron execution tested
[OK] Controlled technical FAIL tested
[OK] Recovery to UP tested
[OK] Operational severity mapped to heartbeat OK
[OK] Missing-ping / silent heartbeat tested
[OK] Cron restored to hourly baseline
```

## Baseline configuration

Healthchecks:

```text
Period: 1 hour
Grace Time: 15 minutes
```

Cron:

```cron
5 * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

## Operational severity mapping

The lab had a missing expected backup folder:

```text
/mnt/so-backup-active/backups/2026/05-MAIO/08-05-26
/mnt/so-backup-active/backups/2026/05-MAIO/08-05-26/secondary
```

`sentinelops-check` returned `exit_code=3` and sent a CRITICAL operational email. The updated runner mapped exit code `3` to Healthchecks OK because the monitoring cycle executed correctly.

Expected log:

```text
[OK] SentinelOps check executed with operational severity. Exit code=3. Heartbeat kept OK.
```

## Missing-ping / silent heartbeat

The Healthchecks check was temporarily accelerated:

```text
Period: 2 minutes
Grace Time: 1 minute
```

The heartbeat cron entry was disabled by moving:

```text
/etc/cron.d/sentinelops-heartbeat
```

to:

```text
/etc/cron.d/sentinelops-heartbeat.disabled
```

Healthchecks detected missing pings and sent DOWN. After restoring the cron file and running the runner manually, Healthchecks returned to UP.

## Pending outside Phase 03

The lab SentinelOps check is correctly reporting a backup issue:

```text
Expected backup folder missing: 08-05-26
```

This is not a Phase 03 failure. It belongs to the next operational correction: investigate why the expected backup folder was not created.
