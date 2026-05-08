# References

This document lists public references used to validate SentinelOps technical decisions.

## Phase 1 — SMTP provider settings

- Hostinger email client configuration: https://www.hostinger.com/support/4305847-set-up-hostinger-email-on-your-applications-and-devices/
- Hostinger SMTP port guidance: https://www.hostinger.com/tutorials/smtp-port

## Phase 1 — msmtp

- Official msmtp documentation: https://marlam.de/msmtp/msmtp.html
- Ubuntu msmtp manual page: https://manpages.ubuntu.com/manpages/trusty/man1/msmtp.1.html

## Phase 1 — Linux security and logging

- Ubuntu AppArmor documentation: https://ubuntu.com/server/docs/how-to/security/apparmor/
- GNU chmod manual: https://www.gnu.org/software/coreutils/manual/html_node/chmod-invocation.html

## Phase 2 — Filesystem layout and Samba

- Filesystem Hierarchy Standard — `/srv`: https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s17.html
- Samba `smb.conf`: https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html

## Phase 2 — Linux mounts and storage checks

- Linux `fstab`: https://man7.org/linux/man-pages/man5/fstab.5.html
- Linux `mount`: https://man7.org/linux/man-pages/man8/mount.8.html
- Linux `findmnt`: https://man7.org/linux/man-pages/man8/findmnt.8.html
- GNU `df`: https://www.gnu.org/software/coreutils/manual/html_node/df-invocation.html
- GNU Findutils: https://www.gnu.org/software/findutils/manual/html_mono/find.html

## Notes

Public project documentation uses placeholders such as `example.com`. Production credentials and real infrastructure identifiers must never be committed.
