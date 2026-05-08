# Phase 01 Test Report — SMTP Relay

## Objective

Validate that a Linux server can send alert emails through an external SMTP provider using `msmtp` and the `sentinela-email` wrapper.

## Scope

This report covers only Phase 01:

- Package installation
- SMTP configuration
- Network connectivity
- TLS validation
- Authenticated email delivery
- Logging through syslog/journalctl
- Wrapper-based delivery

Out of scope:

- Disk monitoring
- Backup freshness checks
- Heartbeat checks
- Cron/systemd automation
- S.M.A.R.T. hardware monitoring

## Sanitized environment

```text
Server hostname: dev-server
Operating system: Ubuntu/Debian-based Linux
SMTP host: smtp.example.com
SMTP port: 465
SMTP encryption: SSL/TLS
SMTP user: alerts@example.com
Recipient: recipient@example.com
```

> Real domain, mailbox, IP addresses and credentials were removed from this public report.

## Test 01 — Confirm target server

Command:

```bash
hostname
whoami
ip a | grep -E "inet "
```

Expected result:

```text
The operator confirms the session is connected to the intended Linux server.
```

Reason:

Running production configuration on the wrong machine is a real operational risk. This validation step prevents accidental deployment to a lab or unrelated host.

## Test 02 — Install SMTP packages

Command:

```bash
sudo apt update
sudo apt install msmtp msmtp-mta ca-certificates -y
```

Expected result:

```text
msmtp and msmtp-mta installed successfully.
```

## Test 03 — Configure permission group

Command:

```bash
sudo groupadd --system sentinela-mail 2>/dev/null || true
sudo usermod -aG sentinela-mail "$USER"
newgrp sentinela-mail
groups
```

Expected result:

```text
sentinela-mail appears in the current user's group list.
```

## Test 04 — Configure `/etc/msmtprc`

Expected file properties:

```bash
sudo chown root:sentinela-mail /etc/msmtprc
sudo chmod 640 /etc/msmtprc
ls -l /etc/msmtprc
```

Expected output pattern:

```text
-rw-r----- 1 root sentinela-mail ... /etc/msmtprc
```

## Test 05 — SMTP connectivity and TLS

Command:

```bash
timeout 15 msmtp --debug --serverinfo --host=smtp.example.com --port=465 --tls=on --tls-starttls=off
```

Expected output pattern:

```text
<-- 220 ESMTP smtp.example.com
<-- 250-AUTH PLAIN LOGIN
TLS session parameters: ...
```

## Issue found — IPv6 preferred but SMTP connection failed

Symptom:

```text
/dev/tcp/smtp.example.com/465 failed
IPv4 direct test worked
```

Diagnostic commands:

```bash
getent ahostsv4 smtp.example.com
getent ahostsv6 smtp.example.com

timeout 10 bash -c '</dev/tcp/smtp.example.com/465' && echo "OK" || echo "FAILED"
timeout 10 bash -c '</dev/tcp/$(getent ahostsv4 smtp.example.com | awk "NR==1 {print \$1}")/465' && echo "IPv4 OK" || echo "IPv4 FAILED"
```

Root cause:

The server preferred IPv6, but IPv6 connectivity for SMTP was incomplete.

Solution applied:

```bash
sudo cp /etc/gai.conf /etc/gai.conf.bak
sudo nano /etc/gai.conf
```

Enable:

```text
precedence ::ffff:0:0/96  100
```

Validation:

```bash
getent ahosts smtp.example.com
```

Expected result:

```text
IPv4 appears before IPv6.
```

## Test 06 — Direct `msmtp` send

Command:

```bash
printf "Subject: Test msmtp direct\nFrom: alerts@example.com\nTo: recipient@example.com\n\nDirect msmtp test from $(hostname).\n" | msmtp -a default recipient@example.com
```

Expected log pattern:

```text
smtpstatus=250
exitcode=EX_OK
```

## Issue found — Authentication failed

Symptom:

```text
smtpstatus=535
Error: authentication failed
```

Root cause:

The SMTP config still used placeholder or wrong mailbox credentials.

Solution:

Use the real SMTP mailbox in both fields:

```text
from alerts@example.com
user alerts@example.com
```

And use the actual mailbox password or provider-approved app password.

## Issue found — AppArmor denied manual log file

Symptom:

```text
apparmor="DENIED" operation="open" profile="msmtp" name="/var/log/msmtp.log"
```

Root cause:

The application profile restricted `msmtp` from writing to a custom log file.

Decision:

Use syslog instead of a manual log file.

Final config:

```text
syslog LOG_MAIL
```

Validation:

```bash
journalctl -n 100 | grep -Ei "smtp|msmtp"
```

Expected result:

```text
msmtp: host=smtp.example.com tls=on auth=on ... smtpstatus=250 ... exitcode=EX_OK
```

## Issue found — generic `mail` command failed

Symptom:

```text
mail: cannot send message: Process exited with a non-zero status
```

Root cause:

The local mail utility added an extra behavior layer and was not needed for this project.

Decision:

Use `msmtp` directly through a project-controlled wrapper.

## Test 07 — Wrapper send

Command:

```bash
echo "Final Phase 01 wrapper test." | sentinela-email recipient@example.com "[TEST] SentinelOps SMTP"
```

Expected log pattern:

```text
smtpstatus=250
exitcode=EX_OK
```

## Acceptance criteria

Phase 01 is accepted when:

```text
[OK] Correct server confirmed
[OK] msmtp installed
[OK] /etc/msmtprc configured with placeholders in public docs only
[OK] SMTP host reachable on port 465
[OK] TLS negotiation works
[OK] Authentication works
[OK] Direct msmtp send returns smtpstatus=250
[OK] sentinela-email wrapper returns smtpstatus=250
[OK] Logs are visible through journalctl/syslog
[OK] Recipient confirms email delivery
```

## Final result

```text
Phase 01 status: PASSED
```
