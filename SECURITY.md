# Security Policy

## Portfolio-safe repository

This repository is intentionally sanitized for public portfolio use.

It must not contain:

- SMTP passwords;
- real `/etc/msmtprc`;
- private domains used in production;
- internal IP addresses;
- customer data;
- real backup contents;
- private heartbeat URLs;
- production-only recipient addresses.

## Reporting issues

For a real deployment, review every configuration example before copying it to a server.

## Operational warning

Do not enable automated email execution or cron/systemd timers before validating:

```bash
/usr/local/bin/sentinelops-check --no-email
```

and confirming that the intended recipients are configured.
