# Security Policy

## Portfolio-safe repository

This repository is intentionally sanitized for public portfolio use.

It must not contain:

- SMTP passwords;
- real `/etc/msmtprc`;
- mailbox app passwords;
- private domains used in production;
- internal IP addresses;
- customer data;
- real backup contents;
- private heartbeat URLs;
- production-only recipient addresses;
- raw production logs.

## Reporting security issues

Do not open public issues containing credentials, real logs, real domains, internal IPs, alert recipients, customer information or secret heartbeat URLs.

## Secrets policy

Never commit:

- SMTP passwords;
- real `/etc/msmtprc`;
- mailbox app passwords;
- customer names;
- internal IP addresses;
- alert recipients;
- heartbeat URLs;
- raw logs;
- real backup contents.

## If a secret is exposed

1. Rotate the affected password or token immediately.
2. Remove the secret from the repository.
3. Rewrite history if the repository is public and the secret was committed.
4. Reconfigure production servers with the new secret.
5. Validate with a controlled SMTP test.

## Operational warning

Do not enable automated email execution or cron/systemd timers before validating:

```bash
/usr/local/bin/sentinelops-check --no-email
```

and confirming that the intended recipients are configured.

For real deployment, review every configuration example before copying it to a server.
