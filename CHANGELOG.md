# Changelog

## v0.2.0-phase-02-core-sentinel

Phase 2 adds the first operational SentinelOps checker.

Added:

- dynamic mount classification through `mounts.conf`;
- active, critical and archived disk roles;
- backup job validation through `backup_jobs.conf`;
- support for one, two, three or more backup jobs;
- per-job fallback monitoring;
- backup daily folder validation;
- warning/high/critical status model;
- email escalation through the Phase 1 `sentinela-email` wrapper;
- lab validation for OK, WARNING, HIGH and CRITICAL states;
- standardized Linux paths for Samba, backups, fallback and logs.

## v0.1.0-phase-01-smtp

Phase 1 established the SMTP alert foundation.

Added:

- Hostinger SMTP integration through `msmtp`;
- syslog/journal logging for sent messages;
- `sentinela-email` wrapper;
- direct SMTP and wrapper validation;
- lab approval for alert transport.
