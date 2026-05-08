# Changelog

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

## 0.1.0 — Phase 01

### Added

- Public project structure.
- Example `msmtp` configuration.
- Example `sentinela-email` wrapper.
- Phase 01 documentation.
- SMTP troubleshooting notes.
- Security guidelines for public repositories.

### Validated in production concept

- SMTP connection over TLS.
- Authenticated delivery through external SMTP provider.
- Logging through syslog/journalctl.
- Wrapper-based email delivery for future monitoring scripts.
