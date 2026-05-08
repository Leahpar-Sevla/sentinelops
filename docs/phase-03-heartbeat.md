# Phase 3 — Dead Man's Switch / External Heartbeat

## Objective

Phase 3 adds an external heartbeat to SentinelOps so the monitoring stack can detect when a server, cron job, network path, or the SentinelOps check runner stops reporting.

The core rule is simple:

```text
If the server is healthy, it pings.
If the SentinelOps check fails technically, it reports failure.
If the server is offline, silent, or unable to reach the internet, the external monitor detects the missing ping.
```

This phase does **not** replace the SentinelOps internal checks. Disk usage, backup freshness, buffer/fallback health, and alert escalation remain the responsibility of `sentinelops-check`.

## Architecture

```text
cron -> /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh -> /usr/local/bin/sentinelops-check -> local checks and alert routing -> Healthchecks.io /start, success, or /fail
```

## Standard naming

Each server must have its own check.

```text
SENTINELOPS-[CLIENTE]-[HOSTNAME]-HEARTBEAT
```

Lab example:

```text
SENTINELOPS-TESTE-LAB-HEARTBEAT
```

Production examples:

```text
SENTINELOPS-JOLIMONT-FILESERVER01-HEARTBEAT
SENTINELOPS-MATRIZ-BACKUP01-HEARTBEAT
```

## One server, one heartbeat

Never reuse a single Healthchecks URL across multiple servers.

Correct:

```text
1 server = 1 Healthchecks check = 1 Ping URL = 1 local config
```

Why: if multiple servers use the same check, one server can fail while another keeps the check green.

## Schedule standard

Default production/lab schedule:

```text
Runner cron: every 1 hour, at minute 05
Healthchecks period: 1 hour
Healthchecks grace time: 15 minutes
```

Cron entry:

```cron
5 * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

## State model

| State | Meaning | Source |
|---|---|---|
| START | Runner started execution | Healthchecks `/start` |
| OK | SentinelOps check completed with exit code `0` | Healthchecks base URL |
| FAIL | Runner executed but SentinelOps failed technically | Healthchecks `/fail` |
| DOWN/SILENT | No ping arrived within period + grace | Healthchecks timeout |

## Severity interpretation

| Event | Detection | Severity | First owner |
|---|---|---|---|
| Disk or backup issue | `sentinelops-check` | WARNING/HIGH/CRITICAL | TI / Gestão based on existing escalation |
| Runner cannot find SentinelOps script | Heartbeat runner | CRITICAL | TI |
| Cron stopped | Healthchecks missing ping | CRITICAL | TI |
| Server powered off | Healthchecks missing ping | CRITICAL | TI + Gestão if persistent |
| Network/Tailscale/internet unavailable | Healthchecks missing ping | CRITICAL | TI + Gestão if persistent |

## Secret handling

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

The repository must only contain placeholders such as:

```bash
HEALTHCHECKS_URL="https://hc-ping.com/REPLACE_WITH_SERVER_UUID"
```

## Local files

Expected server-side files:

```text
/etc/sentinelops/sentinelops.conf
/opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
/etc/cron.d/sentinelops-heartbeat
/var/log/sentinelops/heartbeat.log
/var/log/sentinelops/heartbeat-cron.log
```

## Operational checklist

- [ ] Create one Healthchecks check per server.
- [ ] Use the standard name `SENTINELOPS-[CLIENTE]-[HOSTNAME]-HEARTBEAT`.
- [ ] Configure period `1 hour` and grace `15 minutes`.
- [ ] Store the real Ping URL only in `/etc/sentinelops/sentinelops.conf`.
- [ ] Install the runner in `/opt/sentinelops/bin/`.
- [ ] Confirm `/usr/local/bin/sentinelops-check` exists and is executable.
- [ ] Test direct `/start` and success ping.
- [ ] Test runner manually.
- [ ] Test cron execution.
- [ ] Test controlled `/fail` behavior.
- [ ] Test missing-ping behavior.
- [ ] Return cron to hourly schedule after tests.

## Official references

- Healthchecks.io Pinging API: https://healthchecks.io/docs/http_api/
- Healthchecks.io check configuration: https://healthchecks.io/docs/configuring_checks/
