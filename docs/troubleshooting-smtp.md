# SMTP Troubleshooting

This document contains common Phase 01 problems and the commands used to isolate them.

## 1. Authentication failed

Symptom:

```text
smtpstatus=535
Error: authentication failed
```

Likely causes:

- Wrong SMTP username.
- Wrong password.
- The `from` address does not match the authenticated mailbox.
- The provider requires an app password or SMTP access enabled.

Fix:

```text
from alerts@example.com
user alerts@example.com
password REAL_LOCAL_PASSWORD_OR_APP_PASSWORD
```

## 2. TLS works but sending fails

Check the provider settings:

```bash
msmtp --debug --serverinfo --host=smtp.example.com --port=465 --tls=on --tls-starttls=off
```

Expected server capabilities usually include authentication methods like:

```text
AUTH PLAIN LOGIN
```

## 3. IPv6 is preferred but broken

Symptom:

```text
/dev/tcp/smtp.example.com/465 fails
IPv4 direct test works
```

Check address order:

```bash
getent ahosts smtp.example.com
```

Test IPv4 specifically:

```bash
SMTP_IPV4=$(getent ahostsv4 smtp.example.com | awk 'NR==1 {print $1}')
timeout 10 bash -c "</dev/tcp/$SMTP_IPV4/465" && echo "IPv4 OK" || echo "IPv4 failed"
```

If IPv4 works and IPv6 does not, consider editing `/etc/gai.conf`:

```bash
sudo cp /etc/gai.conf /etc/gai.conf.bak
sudo nano /etc/gai.conf
```

Enable:

```text
precedence ::ffff:0:0/96  100
```

## 4. AppArmor denies manual log file writes

Symptom:

```text
apparmor="DENIED" operation="open" profile="msmtp" name="/var/log/msmtp.log"
```

Recommended approach:

Use syslog instead of a manual log file:

```text
syslog LOG_MAIL
```

Then query logs with:

```bash
journalctl -n 100 | grep -Ei "smtp|msmtp"
```

## 5. Generic mail command fails

Symptom:

```text
mail: cannot send message: Process exited with a non-zero status
```

Recommended approach:

Use the SentinelOps wrapper:

```bash
echo "Test" | sentinela-email recipient@example.com "[TEST] SentinelOps SMTP"
```

Why:

The wrapper keeps email delivery predictable and avoids extra behavior from local mail utilities.

## 6. SMTP accepted but email not in inbox

SMTP success means the provider accepted the message for delivery. It does not guarantee the user saw it.

Check:

- Spam folder.
- Mailbox filters.
- Quarantine.
- Recipient address.
- Provider delivery logs if available.
