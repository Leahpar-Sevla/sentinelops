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

1. **Proactive monitoring** - detect backup, disk, fallback and heartbeat issues early.
2. **Simple operations** - use Bash and standard Linux tools where a full NOC stack would be excessive.
3. **Escalation discipline** - separate operational alerts from infrastructure silence.
4. **Portfolio-safe engineering** - document architecture, tests, runbooks and decisions without exposing secrets.

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
├── msmtp + sentinela-email
│   └── outbound alert delivery
│
├── sentinelops-check
│   ├── filesystems
│   ├── daily backup folders
│   ├── backup jobs
│   ├── fallback buffers
│   └── WARNING / HIGH / CRITICAL escalation
│
├── sentinelops-operational-cycle
│   ├── executes sentinelops-check
│   ├── executes sentinelops-smart-check
│   └── returns the highest operational severity
│
├── sentinelops-heartbeat-runner.sh
│   ├── /start ping
│   ├── executes the operational cycle
│   ├── maps operational severity to heartbeat OK
│   └── sends /fail only for technical runner failures
│
└── cron
    └── scheduled execution
```

External visibility:

```text
Healthchecks.io
├── detects missing pings
├── detects runner technical failure
├── alerts when cron/server/network becomes silent
└── confirms recovery
```

---

## Phase 1 - SMTP Foundation

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

## Phase 2 - Core Availability Sentinel

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

## Phase 3 - External Heartbeat / Dead Man's Switch

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

## Phase 4 - Operational Hardening

Phase 4 adds operational hardening after heartbeat validation.

It validates:

- log retention with logrotate;
- hardened log permissions;
- heartbeat runner locking;
- correct mapping between operational severity and heartbeat health;
- operational cycle wrapper;
- S.M.A.R.T. disk health checks;
- detection of disk risk without relying only on overall SMART `PASSED`;
- reduced cron log noise.

Expected contract:

| SentinelOps operational cycle | Heartbeat runner |
|---|---|
| Exit `0` | Exit `0` |
| Exit `1`, `2`, or `3` | Exit `0`, because the cycle executed |
| Technical runner/config/script/curl failure | non-zero and Healthchecks `/fail` |

See:

```text
docs/phase-04-operational-hardening.md
docs/validation/phase-04-lab-validation.md
PHASE_04_VALIDATION_SUMMARY.md
```

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
├── README.md
├── CHANGELOG.md
├── LICENSE
├── SECURITY.md
├── PROJECT_STRUCTURE.md
├── PHASE_02_VALIDATION_SUMMARY.md
├── PHASE_03_VALIDATION_SUMMARY.md
├── PHASE_04_VALIDATION_SUMMARY.md
├── config/
│   ├── backup_jobs.conf.example
│   ├── mounts.conf.example
│   ├── msmtprc.example
│   └── sentinelops.conf.example
├── scripts/
│   ├── install-phase01.example.sh
│   ├── sentinela-email.example
│   ├── sentinelops-check.example
│   ├── sentinelops-heartbeat-runner.sh
│   ├── sentinelops-operational-cycle.example
│   └── sentinelops-smart-check.example
├── examples/
│   ├── cron.d/
│   │   └── sentinelops-heartbeat
│   └── logrotate.d/
│       └── sentinelops
├── tests/
│   ├── phase-02-test-plan.md
│   ├── phase-03-heartbeat-test-plan.md
│   ├── phase-03-lab-results.md
│   └── test-phase02-lab-scenarios.sh
├── docs/
│   ├── phase-01-smtp-foundation.md
│   ├── phase-02-core-availability-sentinel.md
│   ├── phase-02-standardization.md
│   ├── phase-03-heartbeat.md
│   ├── phase-04-operational-hardening.md
│   ├── references.md
│   ├── adr/
│   ├── runbooks/
│   ├── troubleshooting/
│   └── validation/
└── production-template/
```

---

## Quick start - SMTP foundation

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

## Quick start - SentinelOps checker

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

## Quick start - External heartbeat

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

## Quick start - Operational hardening

Install the Phase 4 examples:

```bash
sudo cp scripts/sentinelops-operational-cycle.example /usr/local/bin/sentinelops-operational-cycle
sudo cp scripts/sentinelops-smart-check.example /usr/local/bin/sentinelops-smart-check
sudo chmod 750 /usr/local/bin/sentinelops-operational-cycle /usr/local/bin/sentinelops-smart-check
```

Install log retention:

```bash
sudo cp examples/logrotate.d/sentinelops /etc/logrotate.d/sentinelops
sudo chown root:root /etc/logrotate.d/sentinelops
sudo chmod 644 /etc/logrotate.d/sentinelops
sudo logrotate -d /etc/logrotate.d/sentinelops
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
- backup contents;
- disk serial numbers from production environments.

Use the examples in this repository only as sanitized templates.

---

## References

See:

```text
docs/references.md
```
