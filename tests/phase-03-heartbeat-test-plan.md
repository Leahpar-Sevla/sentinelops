# Phase 3 — Heartbeat Test Plan

## Purpose

Validate that SentinelOps Phase 3 can detect:

1. Successful execution.
2. Technical failure during execution.
3. Cron execution.
4. Missing heartbeat / silent server condition.

## Preconditions

- Healthchecks check exists.
- Check name follows: `SENTINELOPS-[CLIENTE]-[HOSTNAME]-HEARTBEAT`.
- Healthchecks schedule is `Period: 1 hour`, `Grace Time: 15 minutes`.
- `/etc/sentinelops/sentinelops.conf` contains a real `HEALTHCHECKS_URL`.
- `/usr/local/bin/sentinelops-check` exists and is executable.
- Runner exists at `/opt/sentinelops/bin/sentinelops-heartbeat-runner.sh`.

## Test 1 — Direct Healthchecks ping

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

## Test 2 — Manual runner execution

```bash
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
echo $?
sudo tail -n 30 /var/log/sentinelops/heartbeat.log
```

Expected result:

```text
exit code: 0
[OK] SentinelOps check completed successfully. Exit code=0
```

## Test 3 — Cron execution proof

Temporarily run every minute:

```cron
* * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

Restart cron:

```bash
sudo systemctl restart cron
```

After 1–2 minutes:

```bash
sudo journalctl -u cron --since "3 minutes ago" --no-pager
sudo tail -n 20 /var/log/sentinelops/heartbeat.log
sudo tail -n 40 /var/log/sentinelops/heartbeat-cron.log
```

Expected result:

```text
(root) CMD (/opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1)
[OK] SentinelOps check completed successfully. Exit code=0
```

Return cron to hourly after the test:

```cron
5 * * * * root /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh >> /var/log/sentinelops/heartbeat-cron.log 2>&1
```

## Test 4 — Controlled FAIL

Backup config:

```bash
sudo cp -a /etc/sentinelops/sentinelops.conf /etc/sentinelops/sentinelops.conf.bak.phase3-failtest
```

Point the runner to a nonexistent script:

```bash
sudo sed -i 's|^SENTINELA_SCRIPT=.*|SENTINELA_SCRIPT="/usr/local/bin/sentinelops-check-inexistente"|' /etc/sentinelops/sentinelops.conf
```

Run the runner:

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

Restore config immediately:

```bash
sudo mv /etc/sentinelops/sentinelops.conf.bak.phase3-failtest /etc/sentinelops/sentinelops.conf
sudo chown root:root /etc/sentinelops/sentinelops.conf
sudo chmod 600 /etc/sentinelops/sentinelops.conf
```

Run the runner again:

```bash
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
echo "runner_exit=$?"
```

Expected result:

```text
runner_exit=0
```

## Test 5 — Missing ping / silent server simulation

Status: pending.

Recommended lab procedure:

1. Temporarily change the Healthchecks check to:
   - Period: `2 minutes`
   - Grace Time: `1 minute`
2. Stop cron:

```bash
sudo systemctl stop cron
```

3. Wait 3–4 minutes.
4. Confirm Healthchecks sends `DOWN`.
5. Restore cron:

```bash
sudo systemctl start cron
sudo /opt/sentinelops/bin/sentinelops-heartbeat-runner.sh
```

6. Restore Healthchecks schedule:
   - Period: `1 hour`
   - Grace Time: `15 minutes`
