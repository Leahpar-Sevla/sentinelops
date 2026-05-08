# Phase 03 Heartbeat Test Plan

## Objective

Validate the external heartbeat layer for SentinelOps.

Phase 03 must prove three separate states:

```text
OK      -> SentinelOps ran successfully.
FAIL    -> Runner executed but the SentinelOps check failed technically.
SILENT  -> Server, cron, network, or monitoring path stopped reporting.
```

## Pre-checks

```bash
sudo grep -E '^(CLIENTE|ENVIRONMENT|HOSTNAME_PADRAO|SENTINELA_SCRIPT|HEARTBEAT_LOG)=' /etc/sentinelops/sentinelops.conf
sudo sh -c 'grep -q "^HEALTHCHECKS_URL=" /etc/sentinelops/sentinelops.conf && echo "HEALTHCHECKS_URL configured" || echo "HEALTHCHECKS_URL missing"'
sudo ls -lah /usr/local/bin/sentinelops-check
sudo ls -lah /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
```

## Test 1 — direct Healthchecks ping

```bash
sudo bash -c '
source /etc/sentinelops/sentinelops.conf

echo "Testing START..."
curl -fsS -m 10 "${HEALTHCHECKS_URL}/start" && echo "START OK"

echo
echo "Testing OK..."
curl -fsS -m 10 "${HEALTHCHECKS_URL}" && echo "PING OK"
'
```

Expected result:

```text
START OK
PING OK
```

## Test 2 — runner manual OK

```bash
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
echo "runner_exit=$?"
sudo tail -n 20 /var/log/sentinelops/heartbeat.log
```

Expected result:

```text
runner_exit=0
[OK] SentinelOps check completed successfully
```

## Test 3 — cron execution

Temporarily change the cron entry to every minute:

```cron
* * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

Restart cron:

```bash
sudo systemctl restart cron
```

Validate:

```bash
sudo journalctl -u cron --since "3 minutes ago" --no-pager
sudo tail -n 20 /var/log/sentinelops/heartbeat.log
sudo tail -n 40 /var/log/sentinelops/heartbeat-cron.log
```

Expected result:

```text
(root) CMD (/opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1)
[OK] SentinelOps check completed successfully
```

Return cron to hourly:

```cron
5 * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

## Test 4 — controlled FAIL

Backup the config:

```bash
sudo cp -a /etc/sentinelops/sentinelops.conf /etc/sentinelops/sentinelops.conf.bak.phase3-failtest
```

Break the script path:

```bash
sudo sed -i 's|^SENTINELA_SCRIPT=.*|SENTINELA_SCRIPT="/usr/local/bin/sentinelops-check-inexistente"|' /etc/sentinelops/sentinelops.conf
```

Run:

```bash
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
echo "runner_exit=$?"
sudo tail -n 20 /var/log/sentinelops/heartbeat.log
```

Expected result:

```text
runner_exit=3
[FAIL] SentinelOps check not found or not executable
```

Restore:

```bash
sudo mv /etc/sentinelops/sentinelops.conf.bak.phase3-failtest /etc/sentinelops/sentinelops.conf
sudo chown root:root /etc/sentinelops/sentinelops.conf
sudo chmod 600 /etc/sentinelops/sentinelops.conf
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
```

Expected recovery:

```text
runner_exit=0
Healthchecks status returns to UP
```

## Test 5 — missing ping / silent server

Temporarily reduce Healthchecks schedule for the lab check:

```text
Period: 2 minutes
Grace Time: 1 minute
```

Stop cron:

```bash
sudo systemctl stop cron
```

Wait 3 to 4 minutes.

Expected result:

```text
Healthchecks sends DOWN notification.
```

Restore:

```bash
sudo systemctl start cron
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
```

Return Healthchecks schedule to:

```text
Period: 1 hour
Grace Time: 15 minutes
```

Expected recovery:

```text
Healthchecks sends UP notification.
```
