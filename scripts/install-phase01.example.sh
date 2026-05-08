#!/usr/bin/env bash

set -euo pipefail

echo "Installing SentinelOps Phase 01 dependencies..."
sudo apt update
sudo apt install msmtp msmtp-mta ca-certificates -y

sudo groupadd --system sentinela-mail 2>/dev/null || true
sudo usermod -aG sentinela-mail "$USER"

echo "Copying example wrapper..."
sudo cp scripts/sentinela-email.example /usr/local/bin/sentinela-email
sudo chmod +x /usr/local/bin/sentinela-email

echo "Next manual steps:"
echo "1. Copy config/msmtprc.example to /etc/msmtprc"
echo "2. Edit /etc/msmtprc with real credentials locally"
echo "3. Apply: sudo chown root:sentinela-mail /etc/msmtprc && sudo chmod 640 /etc/msmtprc"
echo "4. Run: tests/check-phase01.sh"
