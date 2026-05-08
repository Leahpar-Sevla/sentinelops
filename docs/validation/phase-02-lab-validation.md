# Phase 2 — Lab Validation Evidence

## Environment

- Server: `dev-server`
- Environment: `lab`
- Alert transport: Phase 1 `sentinela-email`
- Backup mode: `backup-jobs`
- Jobs tested: `main`, `secondary`

## Clean state

Expected:

```text
Status: OK
exit=0
```

Validated.

## Fallback file in main

Simulated file in:

```text
/var/lib/sentinelops/backup-fallback/main/
```

Expected:

```text
Status: WARNING
exit=1
```

Validated.

## Missing secondary backup folder

Simulated by renaming the expected `secondary` backup folder.

Expected:

```text
Status: CRITICAL
exit=3
```

Validated.

## Archived disk read-write

Simulated by remounting `/mnt/so-archive` as `rw`.

Expected:

```text
Status: HIGH
exit=2
```

Validated.

## Warning email

Expected:

```text
WARNING -> support
smtpstatus=250
exitcode=EX_OK
```

Validated in lab.

## Critical email

Expected:

```text
CRITICAL -> management
CRITICAL -> support
smtpstatus=250
exitcode=EX_OK
```

Validated in lab.

## Conclusion

Phase 2 is approved in the lab environment.
