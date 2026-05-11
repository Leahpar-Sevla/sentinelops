# Changelog

## Phase 04 — Operational Hardening

### Added

- Added Phase 04 operational hardening documentation.
- Added lab validation notes for logrotate, runner hardening and S.M.A.R.T.
- Added example logrotate rule for `/var/log/sentinelops/*.log`.
- Added `sentinelops-operational-cycle.example`.
- Added `sentinelops-smart-check.example`.
- Added Phase 04 validation summary.

### Changed

- Updated repository status to mark Phase 04 as validated in lab.
- Documented that operational CRITICAL does not mark Healthchecks as failed when the cycle executed.

### Security

- Documented that real Healthchecks URLs, alert recipients, internal paths with customer data, raw logs and disk serial numbers must not be committed.

## v0.3.0-phase-03-external-heartbeat

Phase 3 adds the external heartbeat / Dead Man's Switch layer.

### Added

- Healthchecks.io heartbeat design.
- `sentinelops-heartbeat-runner.sh`.
- `/start`, success and `/fail` ping model.
- Secure `HEALTHCHECKS_URL` placeholder in `sentinelops.conf.example`.
- Example `/etc/cron.d/sentinelops-heartbeat`.
- Phase 3 architecture documentation.
- Phase 3 validation summary.
- Phase 3 test plan and lab results.

### Changed

- The heartbeat runner now separates operational severity from technical failure.
- `sentinelops-check` exit codes `1`, `2`, and `3` keep Healthchecks OK because the monitoring cycle executed and SentinelOps handles the operational alert.
- Missing script, permission error, missing config, or unexpected exit code still signal Healthchecks FAIL.
- Repository line ending rules were hardened with `.gitattributes`.

### Validated in lab

- Direct Healthchecks `/start` ping.
- Direct Healthchecks success ping.
- Runner manual execution with `runner_exit=0`.
- Cron execution using a temporary every-minute schedule.
- Controlled technical failure with invalid `SENTINELA_SCRIPT`.
- Healthchecks DOWN notification.
- Recovery to UP after restoring the config.
- Operational CRITICAL while Healthchecks remains UP.
- Missing-ping / silent heartbeat test.
- Final cron restored to hourly schedule.

### Pending outside Phase 3

- Investigate why the expected backup folder `08-05-26` was not created in the lab.

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

## v0.1.1-phase-01-portfolio-hardening

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
