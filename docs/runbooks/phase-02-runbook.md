# Runbook — Phase 2

## Manual check

```bash
/usr/local/bin/sentinelops-check --no-email
echo $?
```

## Run with email

```bash
/usr/local/bin/sentinelops-check
```

## Check logs

```bash
journalctl -n 80 | grep -Ei "sentinelops-check|msmtp|smtpstatus|EX_OK"
```

## Validate mounts

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINTS
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS
df -hT
df -ih
```

## Validate configuration

```bash
cat /etc/sentinelops/sentinelops.conf
cat /etc/sentinelops/mounts.conf
cat /etc/sentinelops/backup_jobs.conf
```

## Common responses

### WARNING — backup fallback contains files

1. Check active backup mount.
2. Check backup job logs.
3. Confirm whether recovery script should move fallback data.
4. Do not ignore fallback accumulation.

### CRITICAL — expected backup folder missing

1. Check active backup disk.
2. Check the backup job source path.
3. Review job logs.
4. Do not delete source files until backup is confirmed.

### HIGH — archived disk is writable

1. Remount as read-only.
2. Investigate why it became writable.
3. Consider archive integrity check.
