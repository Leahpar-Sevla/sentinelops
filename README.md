# SentinelOps

**Proactive Linux Server Monitoring and Alerting**

SentinelOps is a lightweight Linux monitoring and alerting project focused on detecting infrastructure problems before they become outages, using small, auditable shell scripts and standard Linux tools.

> This repository is a portfolio-safe version. It does not contain production credentials, private domains, internal IPs, customer data, real alert recipients, SMTP passwords or private heartbeat URLs.

---

## Project vision

A server should not wait for a human to discover operational problems manually. It should report its own health and escalate issues based on severity.

SentinelOps is designed around four ideas:

1. **Proactive monitoring** — detect disk, backup and server health problems early.
2. **Simple operations** — use Bash and standard Linux tools instead of heavy platforms for small environments.
3. **Alert escalation** — separate routine maintenance from critical incidents.
4. **Production discipline** — use logs, checklists, documentation and safe configuration examples.

---

## Current status

| Phase | Name | Status |
|---|---|---|
| Phase 1 | SMTP Foundation | Completed in lab |
| Phase 2 | Core Availability Sentinel | Completed in lab |
| Phase 3 | Heartbeat / scheduler / cooldown | Planned |
| Phase 4 | Archive integrity / S.M.A.R.T. / hardening | Planned |

---

## Phase 1 — SMTP Foundation

Phase 1 validates outbound email delivery from a Linux server using `msmtp`.

Validated concepts:

- SMTP relay configuration;
- TLS over port 465;
- system-wide `msmtp` configuration;
- IPv4/IPv6 connectivity troubleshooting;
- syslog/journalctl logging;
- reusable `sentinela-email` wrapper;
- safe public examples with placeholders;
- production-style test evidence without exposing secrets.

See:

```text
docs/fase-01-smtp.md
docs/fase-01-test-report.md
docs/runbook-phase-01.md
docs/troubleshooting-smtp.md
docs/phase-01-smtp-foundation.md
```

### Phase 1 production lessons

| Problem | Root cause | Solution |
|---|---|---|
| SMTP authentication failed | Placeholder or wrong mailbox credentials | Use the real SMTP mailbox as both `user` and `from` |
| TCP port failed using domain | System preferred IPv6 but IPv6 connectivity was incomplete | Prefer IPv4 using `/etc/gai.conf` when justified |
| Manual log file permission denied | AppArmor profile blocked direct log file writes | Use `syslog LOG_MAIL` and inspect with `journalctl` |
| Generic `mail` command failed | Extra local mail layer changed behavior | Use a dedicated `sentinela-email` wrapper with `msmtp` directly |

---

## Phase 2 — Core Availability Sentinel

Phase 2 introduces the first operational SentinelOps checker.

It monitors:

- critical filesystems;
- active backup disks;
- archived read-only disks;
- daily backup folders;
- one, two, three or more backup jobs;
- fallback folders;
- warning and critical email escalation.

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

## Repository structure

```text
sentinelops/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── SECURITY.md
├── .gitignore
├── config/
│   ├── msmtprc.example
│   ├── sentinelops.conf.example
│   ├── mounts.conf.example
│   └── backup_jobs.conf.example
├── scripts/
│   ├── install-phase01.example.sh
│   ├── sentinela-email.example
│   └── sentinelops-check.example
├── tests/
│   ├── check-phase01.sh
│   ├── test-msmtp-direct.sh
│   ├── test-network-smtp.sh
│   ├── test-sentinela-email.sh
│   ├── phase-02-test-plan.md
│   └── test-phase02-lab-scenarios.sh
├── docs/
│   ├── fase-01-smtp.md
│   ├── fase-01-test-report.md
│   ├── phase-01-smtp-foundation.md
│   ├── phase-02-core-availability-sentinel.md
│   ├── phase-02-standardization.md
│   ├── references.md
│   ├── validation/
│   ├── runbooks/
│   ├── troubleshooting/
│   └── adr/
└── production-template/
```

---

## Quick start — Phase 1 SMTP

Install required packages:

```bash
sudo apt update
sudo apt install msmtp msmtp-mta ca-certificates -y
```

Install the example wrapper:

```bash
sudo cp scripts/sentinela-email.example /usr/local/bin/sentinela-email
sudo chmod +x /usr/local/bin/sentinela-email
```

Create a local production configuration from the example:

```bash
sudo cp config/msmtprc.example /etc/msmtprc
sudo nano /etc/msmtprc
sudo chown root:sentinela-mail /etc/msmtprc
sudo chmod 640 /etc/msmtprc
```

Run a controlled test:

```bash
echo "SentinelOps SMTP test" | sentinela-email destination@example.com "[TEST] SentinelOps SMTP"
```

Check logs:

```bash
journalctl -n 100 | grep -Ei "smtp|msmtp"
```

Expected result:

```text
smtpstatus=250
exitcode=EX_OK
```

---

## Quick start — Phase 2 checker

Copy example configuration files to `/etc/sentinelops` and adjust them for the server:

```bash
sudo mkdir -p /etc/sentinelops
sudo cp config/sentinelops.conf.example /etc/sentinelops/sentinelops.conf
sudo cp config/mounts.conf.example /etc/sentinelops/mounts.conf
sudo cp config/backup_jobs.conf.example /etc/sentinelops/backup_jobs.conf
```

Install the checker:

```bash
sudo cp scripts/sentinelops-check.example /usr/local/bin/sentinelops-check
sudo chmod +x /usr/local/bin/sentinelops-check
```

Manual validation without email:

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

## Security note

Never commit:

- SMTP password;
- real `/etc/msmtprc`;
- mailbox app passwords;
- real customer names;
- internal IP addresses;
- private alert recipients;
- heartbeat URLs;
- raw production logs;
- backup contents.

Use the examples in this repository only as sanitized templates.

---

## References

See:

```text
docs/references.md
```
