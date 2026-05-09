# Phase 03 Heartbeat Test Plan

## Objective

Validate four states:

```text
OK              -> SentinelOps ran successfully.
OPERATIONAL     -> SentinelOps ran and detected operational severity; heartbeat remains OK.
FAIL            -> Runner executed but failed technically.
SILENT          -> Server, cron, network, or monitoring path stopped reporting.
```

## Test 1 — direct Healthchecks ping

```bash
sudo bash -c '
source /etc/sentinelops/sentinelops.conf

curl -fsS -m 10 "${HEALTHCHECKS_URL}/start" && echo "START OK"
curl -fsS -m 10 "${HEALTHCHECKS_URL}" && echo "PING OK"
'
```

## Test 2 — runner manual OK or operational severity

```bash
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
echo "runner_exit=$?"
sudo tail -n 20 /var/log/sentinelops/heartbeat.log
```

Expected result when `sentinelops-check` returns `0`:

```text
runner_exit=0
[OK] SentinelOps check completed without operational alerts
```

Expected result when `sentinelops-check` returns `1`, `2`, or `3`:

```text
runner_exit=0
[OK] SentinelOps check executed with operational severity. Exit code=3. Heartbeat kept OK.
```

## Test 3 — controlled technical FAIL

```bash
sudo cp -a /etc/sentinelops/sentinelops.conf /etc/sentinelops/sentinelops.conf.bak.phase3-failtest
sudo sed -i 's|^SENTINELA_SCRIPT=.*|SENTINELA_SCRIPT="/usr/local/bin/sentinelops-check-inexistente"|' /etc/sentinelops/sentinelops.conf

sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
echo "runner_exit=$?"
sudo tail -n 20 /var/log/sentinelops/heartbeat.log
```

Expected result:

```text
runner_exit=3
[FAIL] SentinelOps check not found or not executable
Healthchecks DOWN/FAIL notification
```

Restore:

```bash
sudo mv /etc/sentinelops/sentinelops.conf.bak.phase3-failtest /etc/sentinelops/sentinelops.conf
sudo chown root:root /etc/sentinelops/sentinelops.conf
sudo chmod 600 /etc/sentinelops/sentinelops.conf
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
```

## Test 4 — missing ping / silent heartbeat

Temporarily reduce Healthchecks schedule:

```text
Period: 2 minutes
Grace Time: 1 minute
```

Disable only the heartbeat cron file:

```bash
sudo mv /etc/cron.d/sentinelops-heartbeat /etc/cron.d/sentinelops-heartbeat.disabled
sudo systemctl restart cron
```

Wait 3 to 4 minutes. Expected result:

```text
Healthchecks sends DOWN notification.
```

Restore:

```bash
sudo mv /etc/cron.d/sentinelops-heartbeat.disabled /etc/cron.d/sentinelops-heartbeat
sudo chown root:root /etc/cron.d/sentinelops-heartbeat
sudo chmod 644 /etc/cron.d/sentinelops-heartbeat
sudo systemctl restart cron
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
```

Return Healthchecks schedule to:

```text
Period: 1 hour
Grace Time: 15 minutes
```
