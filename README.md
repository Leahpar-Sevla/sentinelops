# SentinelOps

**Proactive Linux server monitoring and alerting**

SentinelOps is a lightweight Linux monitoring and alerting project focused on preventing server outages before users notice them.

It monitors:

- critical filesystems;
- active backup disks;
- archived read-only disks;
- daily backup folders;
- one, two, three or more backup jobs;
- fallback folders;
- warning and critical email escalation.

> This repository is portfolio-safe. It does not include production passwords, real SMTP credentials, internal IPs, customer data, private heartbeat URLs or real backup files.

---

## Project vision

A server should not wait for a human to discover operational problems manually. It should report its own health and escalate issues based on severity.

SentinelOps is designed for small Linux server environments where backup reliability and disk availability are critical.

---

## Current status

| Phase | Name | Status |
|---|---|---|
| Phase 1 | SMTP Foundation | Completed in lab |
| Phase 2 | Core Availability Sentinel | Completed in lab |
| Phase 3 | Heartbeat / scheduler / cooldown | Planned |

---

## Phase 1 — SMTP Foundation

Phase 1 validates alert transport.

Validated:

- `msmtp`;
- SMTP over TLS;
- Hostinger SMTP relay;
- syslog/journal logging;
- `sentinela-email` wrapper.

See:

```text
docs/phase-01-smtp-foundation.md
```

---

## Phase 2 — Core Availability Sentinel

Phase 2 introduces the first real SentinelOps checker.

Validated:

- clean state returns `OK`;
- fallback file returns `WARNING`;
- missing backup folder returns `CRITICAL`;
- archived disk remounted as read-write returns `HIGH`;
- warning email goes to support;
- critical email goes to management and support.

See:

```text
docs/phase-02-core-availability-sentinel.md
docs/validation/phase-02-lab-validation.md
```

---

## Standard paths

SentinelOps separates Linux technical paths from Samba visual names.

Technical paths:

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

A Samba share can have a friendly name such as `Atendimentos`, while the internal Linux path remains standardized.

See:

```text
docs/phase-02-standardization.md
docs/server-folder-standardization.txt
```

---

## Configuration model

The base script is environment-independent. Server-specific behavior lives in:

```text
/etc/sentinelops/sentinelops.conf
/etc/sentinelops/mounts.conf
/etc/sentinelops/backup_jobs.conf
```

Example files are available in:

```text
config/
```

---

## Main script

```text
scripts/sentinelops-check.example
```

In production, copy it to:

```bash
sudo cp scripts/sentinelops-check.example /usr/local/bin/sentinelops-check
sudo chmod +x /usr/local/bin/sentinelops-check
```

Manual validation:

```bash
/usr/local/bin/sentinelops-check --no-email
echo $?
```

---

## Exit codes

| Status | Exit code |
|---|---:|
| OK | 0 |
| WARNING | 1 |
| HIGH | 2 |
| CRITICAL | 3 |
| Unknown/internal | 4 |

---

## Email escalation

| Severity | Recipient behavior |
|---|---|
| WARNING | Support |
| HIGH | Support |
| CRITICAL | Management + Support |

Phase 2 intentionally does not implement alert cooldown yet. That belongs to Phase 3.

---

## Documentation

```text
docs/
├── phase-01-smtp-foundation.md
├── phase-02-core-availability-sentinel.md
├── phase-02-standardization.md
├── validation/phase-02-lab-validation.md
├── runbooks/phase-02-runbook.md
└── troubleshooting/phase-02-troubleshooting.md
```

---

## References

The project design uses standard Linux tools and conventions:

- Filesystem Hierarchy Standard for `/srv`;
- Samba `smb.conf` share mapping;
- Linux `fstab` with `UUID`;
- `findmnt`, `df`, `find`, `logger`;
- `msmtp` for alert transport.

Reference links are listed in:

```text
docs/references.md
```
