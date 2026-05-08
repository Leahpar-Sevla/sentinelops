# Changelog

## v0.2.1-phase-docs-merge

Documentation maintenance release.

### Fixed

- Merged Phase 1 documentation details back into the public README.
- Restored Phase 1 hardening notes in the changelog.
- Restored Phase 1 SMTP and security references.
- Kept Phase 2 Core Availability Sentinel documentation and examples.

## v0.2.0-phase-02-core-sentinel

Phase 2 adds the first operational SentinelOps checker.

### Added

- Dynamic mount classification through `mounts.conf`.
- Active, critical and archived disk roles.
- Backup job validation through `backup_jobs.conf`.
- Support for one, two, three or more backup jobs.
- Per-job fallback monitoring.
- Backup daily folder validation.
- Warning/high/critical status model.
- Email escalation through the Phase 1 `sentinela-email` wrapper.
- Lab validation for OK, WARNING, HIGH and CRITICAL states.
- Standardized Linux paths for Samba, backups, fallback and logs.
- Production template for `/etc/sentinelops`.
- Phase 2 runbook, troubleshooting guide, ADRs and test plan.

## 0.1.1 — Phase 01 portfolio hardening

### Added

- Sanitized Phase 01 test report.
- Runbook for SMTP troubleshooting.
- ADR documents explaining technical decisions.
- Network and SMTP test scripts.
- Local Phase 01 validation script.
- Security policy.
- References document.

### Improved

- README now includes production lessons learned.
- Troubleshooting now covers IPv6 preference and AppArmor log denial.

## v0.1.0-phase-01-smtp

Phase 1 established the SMTP alert foundation.

### Added

- Public project structure.
- Example `msmtp` configuration.
- Example `sentinela-email` wrapper.
- Phase 01 documentation.
- SMTP troubleshooting notes.
- Security guidelines for public repositories.
- Hostinger SMTP integration through `msmtp`.
- Syslog/journal logging for sent messages.
- Direct SMTP and wrapper validation.

### Validated in lab

- SMTP connection over TLS.
- Authenticated delivery through external SMTP provider.
- Logging through syslog/journalctl.
- Wrapper-based email delivery for future monitoring scripts.
