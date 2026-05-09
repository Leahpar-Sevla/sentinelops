# SentinelOps

![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-server%20monitoring-FCC624?logo=linux&logoColor=black)
![Status](https://img.shields.io/badge/status-lab%20validated-blue)
![License](https://img.shields.io/github/license/Leahpar-Sevla/sentinelops)

**Proactive Linux server monitoring and alerting with Bash, msmtp, cron, Healthchecks.io and operational runbooks.**

SentinelOps is a lightweight monitoring project focused on small and medium Linux environments where reliability, auditability and simple operations matter more than heavyweight monitoring platforms.

> Portfolio-safe repository: no production credentials, SMTP passwords, private domains, internal IP addresses, customer data, real alert recipients, private heartbeat URLs or raw production logs are stored here.

---

## Why this project exists

A server should not wait for a human to manually discover that a backup failed, a disk filled up, or a monitoring script stopped running.

SentinelOps is built around four principles:

1. **Proactive monitoring** â€” detect backup, disk, fallback and heartbeat issues early.
2. **Simple operations** â€” use Bash and standard Linux tools where a full NOC stack would be excessive.
3. **Escalation discipline** â€” separate operational alerts from infrastructure silence.
4. **Portfolio-safe engineering** â€” document architecture, tests, runbooks and decisions without exposing secrets.

---

## Current status

| Phase | Area | Status |
|---|---|---|
| Phase 1 | SMTP Foundation | Completed in lab |
| Phase 2 | Core Availability Sentinel | Completed in lab |
| Phase 3 | External Heartbeat / Dead Man's Switch | Validated in lab |
| Phase 4 | Logs, retention, S.M.A.R.T. and hardening | Validated in lab |

---

## Architecture overview

```text
Linux server
  â”œâ”€â”€ msmtp + sentinela-email
  â”‚     â””â”€â”€ outbound alert delivery
  â”‚
  â”œâ”€â”€ sentinelops-check
  â”‚     â”œâ”€â”€ filesystems
  â”‚     â”œâ”€â”€ daily backup folders
  â”‚     â”œâ”€â”€ backup jobs
  â”‚     â”œâ”€â”€ fallback buffers
  â”‚     â””â”€â”€ WARNING / HIGH / CRITICAL escalation
  â”‚
  â”œâ”€â”€ sentinelops-heartbeat-runner.sh
  â”‚     â”œâ”€â”€ /start ping
  â”‚     â”œâ”€â”€ executes sentinelops-check
  â”‚     â”œâ”€â”€ maps operational severity to heartbeat OK
  â”‚     â””â”€â”€ sends /fail only for technical runner failures
  â”‚
  â””â”€â”€ cron
        â””â”€â”€ scheduled execution
```

External visibility:

```text
Healthchecks.io
  â”œâ”€â”€ detects missing pings
  â”œâ”€â”€ detects runner technical failure
  â”œâ”€â”€ alerts when cron/server/network becomes silent
  â””â”€â”€ confirms recovery
```

---

## Phase 1 â€” SMTP Foundation

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
docs/phase-01-smtp-foundation.md
docs/runbooks/phase-02-runbook.md
docs/troubleshooting/phase-02-troubleshooting.md
```

---

## Phase 2 â€” Core Availability Sentinel

Phase 2 introduces the first operational SentinelOps checker.

It monitors:

- critical filesystems;
- active backup disks;
- archived read-only disks;
- daily backup folders;
- one, two, three or more backup jobs;
- fallback folders;
- warning and critical email escalation.

Validated states:

| State | Exit code | Meaning |
|---|---:|---|
| OK | 0 | No actionable issue |
| WARNING | 1 | Routine support action |
| HIGH | 2 | Elevated operational risk |
| CRITICAL | 3 | Immediate operational action |
| Unknown/internal | 4 | Unexpected internal condition |

See:

```text
docs/phase-02-core-availability-sentinel.md
docs/validation/phase-02-lab-validation.md
PHASE_02_VALIDATION_SUMMARY.md
```

---

## Phase 3 â€” External Heartbeat / Dead Man's Switch

Phase 3 adds an external heartbeat using Healthchecks.io.

It validates:

- `/start` ping when the runner begins;
- success ping when the SentinelOps cycle executes;
- `/fail` ping for technical runner/check failure;
- operational CRITICAL alerts without marking Healthchecks as failed;
- cron-driven execution;
- missing-ping / silent heartbeat detection;
- recovery to UP after restoring the heartbeat.

The runner deliberately separates operational severity from heartbeat health:

| SentinelOps result | Healthchecks result |
|---|---|
| Exit `0` | OK |
| Exit `1`, `2`, or `3` | OK, because the cycle executed and SentinelOps handles the alert |
| Missing script, permission issue, missing config or unexpected exit code | FAIL |
| No ping | DOWN after Period + Grace |

Default schedule:

```cron
5 * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

See:

```text
docs/phase-03-heartbeat.md
PHASE_03_VALIDATION_SUMMARY.md
tests/phase-03-heartbeat-test-plan.md
tests/phase-03-lab-results.md
```

---

## Phase 4 â€” Operational Hardening

Phase 04 adds operational hardening after heartbeat validation.

It validates:

- log retention with logrotate;
- hardened log permissions;
- heartbeat runner locking;
- correct mapping between operational severity and heartbeat health;
- operational cycle wrapper;
- S.M.A.R.T. disk health checks;
- detection of disk risk without relying only on overall SMART PASSED;
- reduced cron log noise.

Expected contract:

| SentinelOps operational cycle | Heartbeat runner |
|---|---|
| Exit 0 | Exit 0 |
| Exit 1, 2, or 3 | Exit 0, because the cycle executed |
| Technical runner/config/script/curl failure | non-zero and Healthchecks /fail |

See:

- docs/phase-04-operational-hardening.md
- docs/validation/phase-04-lab-validation.md
- PHASE_04_VALIDATION_SUMMARY.md


---

## Standard paths

SentinelOps separates Linux technical paths from Samba visual names.

```text
/srv/sentinelops/shares/main
/srv/sentinelops/shares/secondary
/srv/sentinelops/shares/tertiary
/mnt/so-data
/mnt/so-backup-active
/mnt/so-archive
/var/lib/sentinelops/backup-fallback
/var/log/sentinelops
/etc/sentinelops
/opt/sentinelops/bin
```

---

## Repository structure

```text
sentinelops/
â”œâ”€â”€ README.md
â”œâ”€â”€ CHANGELOG.md
â”œâ”€â”€ LICENSE
â”œâ”€â”€ SECURITY.md
â”œâ”€â”€ PROJECT_STRUCTURE.md
â”œâ”€â”€ PHASE_02_VALIDATION_SUMMARY.md
â”œâ”€â”€ PHASE_03_VALIDATION_SUMMARY.md
â”œâ”€â”€ config/
â”‚   â”œâ”€â”€ backup_jobs.conf.example
â”‚   â”œâ”€â”€ mounts.conf.example
â”‚   â”œâ”€â”€ msmtprc.example
â”‚   â””â”€â”€ sentinelops.conf.example
â”œâ”€â”€ scripts/
â”‚   â”œâ”€â”€ install-phase01.example.sh
â”‚   â”œâ”€â”€ sentinela-email.example
â”‚   â”œâ”€â”€ sentinelops-check.example
â”‚   â””â”€â”€ sentinelops-heartbeat-runner.sh
â”œâ”€â”€ examples/
â”‚   â””â”€â”€ cron.d/
â”‚       â””â”€â”€ sentinelops-heartbeat
â”œâ”€â”€ tests/
â”‚   â”œâ”€â”€ phase-02-test-plan.md
â”‚   â”œâ”€â”€ phase-03-heartbeat-test-plan.md
â”‚   â”œâ”€â”€ phase-03-lab-results.md
â”‚   â””â”€â”€ test-phase02-lab-scenarios.sh
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ phase-01-smtp-foundation.md
â”‚   â”œâ”€â”€ phase-02-core-availability-sentinel.md
â”‚   â”œâ”€â”€ phase-02-standardization.md
â”‚   â”œâ”€â”€ phase-03-heartbeat.md
â”‚   â”œâ”€â”€ references.md
â”‚   â”œâ”€â”€ adr/
â”‚   â”œâ”€â”€ runbooks/
â”‚   â”œâ”€â”€ troubleshooting/
â”‚   â””â”€â”€ validation/
â””â”€â”€ production-template/
```

---

## Quick start â€” SMTP foundation

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

---

## Quick start â€” SentinelOps checker

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

## Quick start â€” External heartbeat

Install the runner:

```bash
sudo install -d -m 750 /opt/sentinelops/bin
sudo cp scripts/sentinelops-heartbeat-runner.sh /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
sudo chown root:root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
sudo chmod 750 /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
```

Configure the local secret only on the server:

```bash
sudo nano /etc/sentinelops/sentinelops.conf
```

Example placeholder:

```bash
HEALTHCHECKS_URL="https://hc-ping.com/REPLACE_WITH_SERVER_UUID"
```

Install the cron example:

```bash
sudo cp examples/cron.d/sentinelops-heartbeat /etc/cron.d/sentinelops-heartbeat
sudo chown root:root /etc/cron.d/sentinelops-heartbeat
sudo chmod 644 /etc/cron.d/sentinelops-heartbeat
sudo systemctl restart cron
```

---

## Security note

Never commit:

- SMTP passwords;
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




