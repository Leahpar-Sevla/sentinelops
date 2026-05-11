# Phase 04 — Operational Hardening

## Scope

Phase 04 hardens SentinelOps after the external heartbeat validation from Phase 03.

Validated areas:

- Log retention with logrotate.
- Hardened log permissions.
- Heartbeat runner hardening.
- Runner lock to prevent overlapping executions.
- Operational cycle wrapper.
- S.M.A.R.T. disk-health monitoring.
- Noise reduction without hiding real failures.
- Local risk register for known hardware issues.

## Core contract

Operational severity must not be confused with heartbeat failure.

| SentinelOps condition | Healthchecks condition |
|---|---|
| Operational OK | OK |
| Operational WARNING / HIGH / CRITICAL | OK, because the cycle executed |
| Runner/config/script/curl technical failure | FAIL |
| Missing ping | DOWN after period + grace |

## Validated result

Expected and validated behavior:

```text
sentinelops-operational-cycle -> exit 3
sentinelops-heartbeat-runner  -> exit 0
```

This means SentinelOps detected a real operational CRITICAL condition, while Healthchecks remained OK because the server, cron and runner executed successfully.

## Log retention

SentinelOps logs are rotated with logrotate:

```text
/var/log/sentinelops/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    create 0640 root root
}
```

Validated behavior:

- Log directory: `root:root`, mode `0750`.
- Active logs: `root:root`, mode `0640`.
- Cron log remains quiet during normal execution.
- All SentinelOps `.log` files are covered by logrotate.

## Runner hardening

The heartbeat runner was hardened with:

- strict Bash mode;
- `umask 027`;
- explicit config loading from `/etc/sentinelops/sentinelops.conf`;
- execution lock with `flock`;
- technical failure detection;
- separation between operational severity and heartbeat health.

A validation bug was found and fixed:

- With `errexit` enabled, an operational exit code `3` from the SentinelOps cycle could prematurely terminate the runner before the exit-code mapping logic.
- The runner must execute the SentinelOps cycle inside `set +e` / `set -e`, capture the exit code, and then apply the mapping.

## Operational cycle wrapper

A new operational wrapper was introduced:

```text
/usr/local/bin/sentinelops-operational-cycle
```

Responsibilities:

1. Run the backup/flow checker.
2. Run the S.M.A.R.T. health checker.
3. Return the highest severity found.

Expected exit codes:

| Exit code | Meaning |
|---:|---|
| 0 | OK |
| 1 | WARNING |
| 2 | HIGH |
| 3 | CRITICAL |

## S.M.A.R.T. disk health

Phase 04 adds a dedicated S.M.A.R.T. checker:

```text
/usr/local/bin/sentinelops-smart-check
```

It validates:

- overall SMART health;
- reallocated sectors;
- pending sectors;
- offline uncorrectable sectors;
- last self-test failure;
- NVMe critical warning;
- NVMe available spare;
- NVMe percentage used;
- NVMe media/data integrity errors.

## Sanitized hardware finding

A lab archive-readonly disk was classified as CRITICAL.

Sanitized evidence:

- role: archive-readonly;
- mountpoint: `/mnt/so-archive`;
- mount options: `ro,nosuid,nodev,noexec,relatime`;
- pending sectors greater than zero;
- offline uncorrectable sectors greater than zero;
- short self-test read failure.

Decision:

- Keep SentinelOps status as CRITICAL.
- Do not write to this disk.
- Do not use this disk for new backup cycles.
- Replace, remove, or decommission after validating archived data elsewhere.

## Noise reduction

Phase 04 separates log responsibility:

| Log | Purpose |
|---|---|
| `/var/log/sentinelops/heartbeat.log` | heartbeat contract and Healthchecks result |
| `/var/log/sentinelops/heartbeat-cron.log` | cron/runner stderr only |
| `/var/log/sentinelops/operational-cycle.log` | operational cycle summary |
| `/var/log/sentinelops/smart-health.log` | detailed S.M.A.R.T. health findings |
| `/var/log/sentinelops/backup-*.log` | backup job logs |

Validation confirmed that cron-style execution leaves `heartbeat-cron.log` empty during normal execution.

## Security notes

Do not commit:

- real Healthchecks URLs;
- SMTP credentials;
- real alert recipients;
- internal IP addresses;
- customer names;
- backup contents;
- raw production logs;
- disk serial numbers from production environments.
