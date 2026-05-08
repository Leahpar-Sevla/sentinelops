# Phase 1 — SMTP Foundation

## Goal

Establish a reliable email transport layer for SentinelOps alerts.

## Validated components

- `msmtp`
- SMTP over TLS
- Hostinger SMTP relay
- `sentinela-email` wrapper
- syslog/journal logging

## Key result

The system can send operational email through the wrapper:

```bash
echo "message" | sentinela-email recipient@example.com "[TEST] SentinelOps"
```

Phase 2 depends on this wrapper.
