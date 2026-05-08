# Phase 01 — SMTP Relay

## Goal

Enable a Linux server to send automated alert emails through an external SMTP provider.

## Why this phase matters

All future SentinelOps checks depend on outbound communication. A monitoring script that detects an incident but cannot notify anyone creates a false sense of security.

## Tools

- `msmtp`
- `msmtp-mta`
- `ca-certificates`
- `journalctl` / syslog
- `sentinela-email` wrapper

## Why msmtp?

`msmtp` is a lightweight SMTP client. In its default mode, it reads an email from standard input and sends it to a configured SMTP server for delivery.

This keeps the alerting layer simple and avoids running a full mail server on each monitored machine.

## Installation

```bash
sudo apt update
sudo apt install msmtp msmtp-mta ca-certificates -y
```

## Permission model

Create a dedicated group for users allowed to read the SMTP configuration:

```bash
sudo groupadd --system sentinela-mail 2>/dev/null || true
sudo usermod -aG sentinela-mail "$USER"
newgrp sentinela-mail
```

Production config permissions:

```bash
sudo chown root:sentinela-mail /etc/msmtprc
sudo chmod 640 /etc/msmtprc
```

## Example config

Copy the example file and edit it locally:

```bash
sudo cp config/msmtprc.example /etc/msmtprc
sudo nano /etc/msmtprc
```

Do not commit the real `/etc/msmtprc` file.

## Recommended logging

Use:

```text
syslog LOG_MAIL
```

Avoid custom log files unless the AppArmor profile and permissions are explicitly reviewed.

## Email wrapper

The project uses a small wrapper named `sentinela-email` so future monitoring scripts do not need to know SMTP details.

Install example:

```bash
sudo cp scripts/sentinela-email.example /usr/local/bin/sentinela-email
sudo chmod +x /usr/local/bin/sentinela-email
```

Test:

```bash
echo "SMTP test" | sentinela-email destination@example.com "[TEST] SentinelOps SMTP"
```

## Logs

Query recent SMTP logs:

```bash
journalctl -n 100 | grep -Ei "smtp|msmtp"
```

Expected result:

```text
smtpstatus=250
exitcode=EX_OK
```

## Acceptance criteria

```text
[ ] Correct server confirmed
[ ] msmtp installed
[ ] SMTP config created locally
[ ] SMTP config permissions restricted
[ ] SMTP host reachable
[ ] TLS negotiation works
[ ] Authenticated send works
[ ] sentinela-email wrapper works
[ ] Logs are visible in journalctl/syslog
[ ] Test email is visible in recipient inbox
```

## Operational lessons from validation

- Always confirm the server before editing production files.
- Do not publish real credentials.
- Prefer syslog over custom log files when AppArmor is active.
- Test IPv4 and IPv6 separately when SMTP connectivity hangs.
- Treat `smtpstatus=250` as provider acceptance, not final human receipt.
