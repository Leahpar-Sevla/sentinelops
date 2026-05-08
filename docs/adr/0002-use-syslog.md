# ADR 0002 — Use syslog/journalctl for msmtp logs

## Status

Accepted

## Context

A manual log file such as `/var/log/msmtp.log` can fail because of Linux permissions or AppArmor profiles.

During testing, custom log file access was denied by the application profile.

## Decision

Use `syslog LOG_MAIL` in the `msmtp` configuration.

## Consequences

Benefits:

- Integrates with the operating system logging stack.
- Avoids custom log file permission issues.
- Can be queried using `journalctl`.

Trade-offs:

- Operators must know how to query system logs.
