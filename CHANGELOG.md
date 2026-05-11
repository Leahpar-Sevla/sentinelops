# Changelog

All notable changes to this project are documented here.

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
- Restored readable Markdown and Bash formatting for Phase 04 files.

### Security

- Documented that real Healthchecks URLs, alert recipients, internal paths with customer data, raw logs and disk serial numbers must not be committed.
