# Phase 04 Lab Validation

## Date

2026-05-09

## Environment

Lab server.

## Validation summary

| Area | Result |
|---|---|
| Git baseline | clean and up to date before Phase 04 work |
| Logrotate rule | validated |
| Log permissions | hardened |
| Runner lock | implemented |
| Runner exit-code mapping | validated |
| Operational wrapper | validated |
| S.M.A.R.T. checker | validated |
| Noise reduction | validated |
| Known disk risk register | created locally |

## Key contracts validated

### Operational CRITICAL does not break heartbeat

Validated:

```text
sentinelops-operational-cycle -> exit 3
sentinelops-heartbeat-runner  -> exit 0
```

Meaning:

- SentinelOps detected a real operational CRITICAL condition.
- Healthchecks remained OK because the server, cron and runner executed.

### Cron log stayed quiet

Validated:

```text
heartbeat-cron.log=0 bytes
```

### S.M.A.R.T. did not rely only on overall PASSED

The lab found a disk where general SMART health reported PASSED, but detailed attributes and short self-test showed a real issue.

Detection criteria validated:

- pending sectors greater than zero;
- offline uncorrectable sectors greater than zero;
- failed short self-test.

The disk remained CRITICAL and was not hidden by an exception.

## Final sanitized state

```text
cycle_exit=3
runner_exit=0
heartbeat-cron.log=0 bytes
log directory owner=root:root
log directory mode=0750
active logs mode=0640
```

## Decision

Phase 04 is validated in lab for:

- log retention;
- operational log hardening;
- heartbeat runner hardening;
- operational/S.M.A.R.T. wrapper;
- S.M.A.R.T. hardware risk detection;
- noise reduction without hiding failures.
