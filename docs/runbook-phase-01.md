# Runbook — Phase 01 SMTP Relay

## Purpose

This runbook guides an operator through diagnosing SentinelOps email delivery problems.

## Severity classification

| Severity | Condition | Action |
|---|---|---|
| INFO | Test email sent successfully | No action required |
| WARNING | Email accepted by SMTP but not visible in inbox | Check spam/quarantine/rules |
| CRITICAL | SMTP auth fails | Validate mailbox, password and provider SMTP settings |
| CRITICAL | SMTP host unreachable | Check DNS, IPv4/IPv6, firewall, ISP or network route |
| CRITICAL | Wrapper missing or not executable | Reinstall `/usr/local/bin/sentinela-email` |

## Fast health check

```bash
hostname
id
msmtp --version
ls -l /etc/msmtprc
journalctl -n 50 | grep -Ei "smtp|msmtp"
```

## Network check

```bash
getent ahosts smtp.example.com
timeout 10 bash -c '</dev/tcp/smtp.example.com/465' && echo "Port 465 OK" || echo "Port 465 failed"
```

## IPv4-specific check

```bash
SMTP_IPV4=$(getent ahostsv4 smtp.example.com | awk 'NR==1 {print $1}')
echo "$SMTP_IPV4"
timeout 10 bash -c "</dev/tcp/$SMTP_IPV4/465" && echo "IPv4 port 465 OK" || echo "IPv4 port 465 failed"
```

## TLS/server info check

```bash
msmtp --debug --serverinfo --host=smtp.example.com --port=465 --tls=on --tls-starttls=off
```

Expected signs:

```text
220 ESMTP
AUTH PLAIN LOGIN
TLS session parameters
```

## Direct send check

```bash
printf "Subject: Direct SMTP test\nFrom: alerts@example.com\nTo: recipient@example.com\n\nDirect msmtp test.\n" | msmtp -a default recipient@example.com
```

## Wrapper send check

```bash
echo "Wrapper test" | sentinela-email recipient@example.com "[TEST] SentinelOps SMTP"
```

## Log check

```bash
journalctl -n 100 | grep -Ei "smtp|msmtp"
```

Good result:

```text
smtpstatus=250
exitcode=EX_OK
```

## Known fixes

### Authentication failed

Check:

- `user` is the full mailbox address.
- `from` matches the authenticated mailbox.
- Password is correct.
- SMTP access is enabled by the provider.

### IPv6 route problem

If IPv4 works but the domain test fails, consider enabling IPv4 preference in `/etc/gai.conf`:

```text
precedence ::ffff:0:0/96  100
```

### AppArmor blocks custom log file

Use:

```text
syslog LOG_MAIL
```

instead of:

```text
logfile /var/log/msmtp.log
```
