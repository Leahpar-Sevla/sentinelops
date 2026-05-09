# Project Structure

SentinelOps is organized as a portfolio-safe operations project.

```text
sentinelops/
├── README.md
├── CHANGELOG.md
├── FILES_MANIFEST.txt
├── LICENSE
├── SECURITY.md
├── PROJECT_STRUCTURE.md
├── PHASE_02_VALIDATION_SUMMARY.md
├── PHASE_03_VALIDATION_SUMMARY.md
├── config/
│   ├── backup_jobs.conf.example
│   ├── mounts.conf.example
│   ├── msmtprc.example
│   └── sentinelops.conf.example
├── scripts/
│   ├── install-phase01.example.sh
│   ├── sentinela-email.example
│   ├── sentinelops-check.example
│   └── sentinelops-heartbeat-runner.sh
├── examples/
│   └── cron.d/
│       └── sentinelops-heartbeat
├── tests/
│   ├── check-phase01.sh
│   ├── phase-02-test-plan.md
│   ├── phase-03-heartbeat-test-plan.md
│   ├── phase-03-lab-results.md
│   ├── test-msmtp-direct.sh
│   ├── test-network-smtp.sh
│   ├── test-phase02-lab-scenarios.sh
│   └── test-sentinela-email.sh
├── docs/
│   ├── phase-01-smtp-foundation.md
│   ├── phase-02-core-availability-sentinel.md
│   ├── phase-02-standardization.md
│   ├── phase-03-heartbeat.md
│   ├── references.md
│   ├── adr/
│   ├── runbooks/
│   ├── troubleshooting/
│   └── validation/
└── production-template/
    ├── etc/sentinelops/
    └── usr/local/bin/
```

## Root files

| File | Purpose |
|---|---|
| `README.md` | Main project landing page |
| `CHANGELOG.md` | Versioned project history |
| `SECURITY.md` | Public security policy |
| `FILES_MANIFEST.txt` | Sanitized file inventory |
| `PHASE_02_VALIDATION_SUMMARY.md` | Phase 2 lab evidence summary |
| `PHASE_03_VALIDATION_SUMMARY.md` | Phase 3 lab evidence summary |

## Directory purpose

| Directory | Purpose |
|---|---|
| `config/` | Sanitized configuration examples |
| `scripts/` | Safe public scripts and script examples |
| `examples/` | Copyable operational snippets such as cron entries |
| `tests/` | Lab validation plans and test scripts |
| `docs/` | Architecture, runbooks, troubleshooting and ADRs |
| `production-template/` | Example server deployment layout without secrets |
