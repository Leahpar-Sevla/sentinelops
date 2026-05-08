# Phase 2 — Standardization

## Purpose

Keep the same SentinelOps code across all servers.

Server-specific differences must be expressed in configuration files, not by editing the script.

## Standard Linux paths

```text
/srv/sentinelops/shares/main
/srv/sentinelops/shares/secondary
/srv/sentinelops/shares/tertiary
/mnt/so-data
/mnt/so-backup-active
/mnt/so-archive
/var/lib/sentinelops/backup-fallback
/var/log/sentinelops
```

## Samba rule

The collaborator sees friendly Samba share names. The Linux path remains standardized.

Example:

```ini
[Atendimentos]
   path = /srv/sentinelops/shares/main

[PISA]
   path = /srv/sentinelops/shares/secondary
```

## Disk rule

Use filesystem labels and UUIDs.

Do not write monitoring logic against `/dev/sda`, `/dev/sdb` or `/dev/sdc`.
