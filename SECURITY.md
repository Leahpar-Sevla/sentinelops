# Security Policy

## Reporting security issues

This is a portfolio project. Do not open public issues containing credentials, real logs, real domains, internal IPs or customer information.

## Secrets policy

Never commit:

- SMTP passwords
- Real `/etc/msmtprc`
- Mailbox app passwords
- Customer names
- Internal IP addresses
- Alert recipients
- Heartbeat URLs
- Raw logs

## If a secret is exposed

1. Rotate the affected password or token immediately.
2. Remove the secret from the repository.
3. Rewrite history if the repository is public and the secret was committed.
4. Reconfigure production servers with the new secret.
5. Validate with a controlled SMTP test.
