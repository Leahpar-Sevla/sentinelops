# ADR 0004 — Handle broken IPv6 preference

## Status

Accepted as conditional guidance

## Context

Some networks resolve SMTP hosts to IPv6 first, even when IPv6 connectivity is incomplete or blocked.

This can make a working SMTP service appear unavailable.

## Decision

If IPv4 connectivity works and IPv6 fails, document a controlled `/etc/gai.conf` change to prefer IPv4:

```text
precedence ::ffff:0:0/96  100
```

## Consequences

Benefits:

- Restores connectivity without hardcoding provider IP addresses.
- Keeps DNS-based SMTP configuration.

Trade-offs:

- Changes address selection behavior system-wide.
- Must be documented and reviewed before production use.
