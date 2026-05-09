# Phase 03 to Phase 04 Transition

## Context

Phase 03 validated the external heartbeat / Dead Man Switch layer using Healthchecks.io.

The heartbeat layer now distinguishes:

- Server, cron and runner alive -> Healthchecks UP
- Operational issue detected -> SentinelOps alert, Healthchecks remains UP
- Technical runner failure -> Healthchecks FAIL
- Missing ping or silent heartbeat -> Healthchecks DOWN
- Recovery -> Healthchecks UP

## Operational finding after Phase 03

After Phase 03 validation, SentinelOps continued sending CRITICAL alerts.

The issue was not the heartbeat layer. The issue was a path contract mismatch between the older backup script and the new SentinelOps backup monitoring standard.

The older backup script wrote to:

    /srv/backup

The SentinelOps backup jobs expected:

    /mnt/so-backup-active/backups

The monitored jobs expected this structure:

    /mnt/so-backup-active/backups/YYYY/MM-MONTH_PT/DD-MM-YY
    /mnt/so-backup-active/backups/YYYY/MM-MONTH_PT/DD-MM-YY/secondary

## Correction performed in lab

The lab backup runner was aligned with:

    /etc/sentinelops/backup_jobs.conf

Validated jobs:

- main
- secondary

Validated destination example:

    /mnt/so-backup-active/backups/2026/05-MAIO/08-05-26
    /mnt/so-backup-active/backups/2026/05-MAIO/08-05-26/secondary

After test data above the configured minimum size was created in both source folders, the backup runner copied the data and sentinelops-check returned:

    Status: OK
    sentinel_exit=0
    No actionable issues detected.

## Lesson learned

Monitoring and backup execution must share the same path contract.

The monitor can be technically correct and still generate noise if the producer of the data writes to an old location.

This finding becomes a Phase 04 hardening input.

## Phase 04 starting point

Phase 04 should focus on operational hardening:

1. Log retention and logrotate.
2. Backup runner hardening.
3. S.M.A.R.T. and disk health checks.
4. Better test data lifecycle.
5. Runbook updates for backup path contract validation.
6. Reduction of alert noise without hiding real failures.

## Phase 03 final state

- External heartbeat validated.
- Controlled FAIL validated.
- Missing ping validated.
- Operational severity separated from heartbeat health.
- Backup path contract mismatch identified and corrected in lab.
- SentinelOps returned to OK after backup alignment.
