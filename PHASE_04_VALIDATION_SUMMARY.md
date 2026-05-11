# Phase 04 Validation Summary

Phase 04 adds operational hardening after the external heartbeat validation from Phase 03.

## Validated in lab

- Log retention with logrotate.
- Hardened log permissions.
- Heartbeat runner hardening.
- Runner lock to prevent overlapping executions.
- Correct exit-code mapping.
- Operational cycle wrapper.
- S.M.A.R.T. checker.
- Detection of disk risk without relying only on overall SMART `PASSED`.
- Reduction of cron log noise.
- Local risk register for known hardware issue.

## Final lab contract

```text
sentinelops-operational-cycle -> exit 3
sentinelops-heartbeat-runner  -> exit 0
```

This is correct when a real operational CRITICAL exists but the server, cron and runner are alive.

## Security

All evidence in this repository is sanitized.

Do not commit:

- real Healthchecks URLs;
- SMTP passwords;
- real alert recipients;
- internal IP addresses;
- customer names;
- raw production logs;
- backup contents;
- disk serial numbers from production systems.
