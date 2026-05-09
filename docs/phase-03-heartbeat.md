# Phase 3 — Dead Man's Switch / External Heartbeat

## Objective

Phase 3 adds an external heartbeat to SentinelOps so the monitoring stack can detect when a server, cron job, network path, or the SentinelOps runner stops reporting.

The core rule is:

```text
If the server is healthy, it pings.
If sentinelops-check detects an operational issue, SentinelOps sends the operational alert and the heartbeat remains OK.
If the server, cron, network or runner becomes silent, Healthchecks.io detects the missing ping.
If the runner cannot execute SentinelOps technically, Healthchecks.io receives FAIL.
```

## Architecture

```text
cron
  -> /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
  -> /usr/local/bin/sentinelops-check
  -> local checks and alert routing
  -> Healthchecks.io /start, success, or /fail
```

## Separation of responsibilities

| Component | Responsibility |
|---|---|
| `sentinelops-check` | Detect backup, disk, fallback, buffer and operational health issues |
| `sentinela-email` | Send operational WARNING/HIGH/CRITICAL alerts |
| `sentinelops-heartbeat-runner.sh` | Prove the monitoring cycle executed |
| Healthchecks.io | Detect missing pings, runner failure, cron silence, server/network outage |

## State model

| State | Meaning | Healthchecks signal |
|---|---|---|
| START | Runner started execution | `/start` |
| OK | SentinelOps check completed without operational alerts | base URL |
| OPERATIONAL SEVERITY | SentinelOps check completed and found WARNING/HIGH/CRITICAL issues | base URL |
| TECHNICAL FAIL | Config/script/permission/unexpected exit failure | `/fail` |
| SILENT/DOWN | No ping arrived within Period + Grace | no ping |

## Exit code mapping

| `sentinelops-check` exit code | Meaning for heartbeat | Healthchecks result |
|---:|---|---|
| `0` | Check ran and found no actionable operational issue | OK |
| `1` | Check ran and found operational severity | OK |
| `2` | Check ran and found operational severity | OK |
| `3` | Check ran and found operational severity | OK |
| any other code | Unexpected technical condition | FAIL |

This prevents the external heartbeat from confusing "backup is missing" with "the server is dead." The operational alert still goes through the SentinelOps email flow.

## Standard naming

Each server must have its own check:

```text
SENTINELOPS-[CLIENTE]-[HOSTNAME]-HEARTBEAT
```

## Schedule standard

```text
Runner cron: every 1 hour, at minute 05
Healthchecks period: 1 hour
Healthchecks grace time: 15 minutes
```

Cron entry:

```cron
5 * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

## Security

The Healthchecks Ping URL is an operational secret.

Allowed:

```text
/etc/sentinelops/sentinelops.conf
private deployment notes
password manager / secure vault
```

Not allowed:

```text
README.md
public GitHub commits
screenshots shared outside the team
hardcoded production URLs in scripts
```

## Lab validation summary

Validated in lab:

- direct `/start` ping;
- direct success ping;
- manual runner success;
- cron execution;
- controlled technical `/fail`;
- recovery after failure;
- operational CRITICAL from `sentinelops-check` while heartbeat stayed OK;
- missing-ping / silent heartbeat test;
- recovery to UP after restoring the cron entry;
- final cron restored to hourly schedule.

## Official references

- Healthchecks.io Pinging API: https://healthchecks.io/docs/http_api/
- Healthchecks.io configuring checks: https://healthchecks.io/docs/configuring_checks/
- Healthchecks.io signaling failures: https://healthchecks.io/docs/signaling_failures/
