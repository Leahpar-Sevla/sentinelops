# Security Guidelines

## Never commit secrets

Do not publish:

- SMTP passwords.
- Production `/etc/msmtprc`.
- Real customer names.
- Internal IP addresses.
- Real alert recipient lists.
- Heartbeat URLs.
- Private logs.

## Use examples only

Public configuration files must use placeholders such as:

```text
alerts@example.com
smtp.example.com
CHANGE_ME
```

## Restrict production config

Recommended permissions:

```bash
sudo chown root:sentinela-mail /etc/msmtprc
sudo chmod 640 /etc/msmtprc
```

This allows only root and approved users in the `sentinela-mail` group to read the SMTP configuration.

## Prefer syslog for msmtp logs

Using syslog avoids custom log permission problems and integrates with Linux logging tools:

```bash
journalctl -n 100 | grep -Ei "smtp|msmtp"
```

## Credential rotation

If credentials are accidentally placed on the wrong machine or exposed, rotate the mailbox password immediately and update the production configuration.
