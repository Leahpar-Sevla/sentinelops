# SentinelOps

**Proactive Linux Server Monitoring and Alerting**

SentinelOps is a lightweight monitoring and alerting project for Linux servers. The goal is to detect infrastructure problems before they become outages, using small, auditable shell scripts and standard Linux tools.

> This repository is a portfolio-safe version. It does not contain production credentials, private domains, internal IPs, customer data, real alert recipients or secret heartbeat URLs.

## Project vision

A server should not wait for a human to discover problems manually. It should report its own health and escalate issues based on severity.

SentinelOps is designed around four ideas:

1. **Proactive monitoring** — detect disk, backup and server health problems early.
2. **Simple operations** — use Bash and standard Linux tools instead of heavy platforms for small environments.
3. **Alert escalation** — separate routine alerts from critical incidents.
4. **Production discipline** — use logs, checklists, documentation and safe configuration examples.

## Current status

```text
[OK] Phase 01 — SMTP relay and email wrapper
[ ] Phase 02 — Disk monitoring and alert severity
[ ] Phase 03 — Backup freshness and buffer checks
[ ] Phase 04 — External heartbeat / dead man's switch
[ ] Phase 05 — Automation with cron or systemd timers
[ ] Phase 06 — Hardware health with S.M.A.R.T.
[ ] Phase 07 — Runbooks, inventory and SLA documentation
```

## Phase 01 summary

Phase 01 validates outbound email delivery from a Linux server using `msmtp`.

Validated concepts:

- SMTP relay configuration
- TLS over port 465
- System-wide `msmtp` configuration
- IPv4/IPv6 connectivity troubleshooting
- Syslog/journalctl logging
- A reusable `sentinela-email` wrapper
- Safer public examples with placeholders
- Production-style test evidence without exposing secrets

## Repository structure

```text
sentinelops/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── SECURITY.md
├── .gitignore
├── config/
│   └── msmtprc.example
├── docs/
│   ├── fase-01-smtp.md
│   ├── fase-01-test-report.md
│   ├── runbook-phase-01.md
│   ├── troubleshooting-smtp.md
│   ├── security.md
│   ├── references.md
│   └── adr/
│       ├── 0001-use-msmtp.md
│       ├── 0002-use-syslog.md
│       ├── 0003-use-email-wrapper.md
│       └── 0004-handle-ipv6-preference.md
├── scripts/
│   ├── install-phase01.example.sh
│   └── sentinela-email.example
└── tests/
    ├── check-phase01.sh
    ├── test-msmtp-direct.sh
    ├── test-network-smtp.sh
    └── test-sentinela-email.sh
```

## Quick start

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

Run a test:

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

## Phase 01 production lessons

During validation, the following problems were intentionally documented because they are common in real environments:

| Problem | Root cause | Solution |
|---|---|---|
| SMTP authentication failed | Placeholder or wrong mailbox credentials | Use the real SMTP mailbox as both `user` and `from` |
| TCP port failed using domain | System preferred IPv6 but IPv6 connectivity was incomplete | Prefer IPv4 using `/etc/gai.conf` when justified |
| Manual log file permission denied | AppArmor profile blocked direct log file writes | Use `syslog LOG_MAIL` and inspect with `journalctl` |
| Generic `mail` command failed | Extra local mail layer changed behavior | Use a dedicated `sentinela-email` wrapper with `msmtp` directly |

See: [`docs/fase-01-test-report.md`](docs/fase-01-test-report.md)

## Security note

Never commit:

- SMTP password
- Real `/etc/msmtprc`
- Real customer names
- Internal IP addresses
- Private alert recipients
- Heartbeat URLs
- Raw production logs

Use the examples in this repository only as sanitized templates.

## References

See [`docs/references.md`](docs/references.md).
