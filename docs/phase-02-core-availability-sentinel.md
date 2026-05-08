# Phase 2 — Core Availability Sentinel

## Goal

Detect operational risks before the server becomes unavailable.

## Scope

Phase 2 monitors:

- critical mounts;
- active backup disks;
- archived read-only disks;
- multiple backup jobs;
- fallback folders;
- temp/buffer folders;
- email escalation.

## What is not included yet

- alert cooldown;
- recovery notifications;
- heartbeat monitoring;
- scheduled automation;
- archive checksum manifests;
- full S.M.A.R.T. integration.

These belong to later phases.

## Configuration files

```text
/etc/sentinelops/sentinelops.conf
/etc/sentinelops/mounts.conf
/etc/sentinelops/backup_jobs.conf
```

## Alert levels

| Level | Meaning | Recipient |
|---|---|---|
| OK | No actionable issue | No email |
| WARNING | Maintenance required | Support |
| HIGH | Operational risk | Support |
| CRITICAL | Immediate action required | Management + Support |

## Lab approval

Phase 2 was approved in lab after successful testing of OK, WARNING, HIGH and CRITICAL flows.
