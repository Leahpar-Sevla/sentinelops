# Troubleshooting — Phase 2

## Alert detected but no email arrived

Check recipients:

```bash
grep -E "WARNING_RECIPIENT|HIGH_RECIPIENT|CRITICAL_RECIPIENT|ALERT_COMMAND" /etc/sentinelops/sentinelops.conf
```

Check SMTP logs:

```bash
journalctl -n 80 | grep -Ei "msmtp|smtpstatus|EX_OK|EX_"
```

## Backup folder missing

Check job config and paths:

```bash
cat /etc/sentinelops/backup_jobs.conf
find /mnt/so-backup-active/backups -maxdepth 5 -type d
```

## Fallback warning

```bash
find /var/lib/sentinelops/backup-fallback -type f -printf '%p|%s|%TY-%Tm-%Td %TH:%TM\n'
```

## Archived disk writable

```bash
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS | grep so-archive
sudo mount -o remount,ro /mnt/so-archive
```

## fstab validation

```bash
sudo findmnt --verify
sudo mount -a
```
