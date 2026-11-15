#!/usr/bin/env bash
# Run on fresh Oracle Cloud Arm VM (Ubuntu 22.04/24.04)
# Usage: curl -fsSL https://raw.githubusercontent.com/YOU/free-cloud-stack/main/scripts/oracle-vm-setup.sh | bash

set -euo pipefail

echo "Setting up Oracle Arm VM for Free Cloud Stack..."

# 1) System update & essentials
sudo apt-get update -y
sudo apt-get install -y \
  docker.io docker-compose-plugin \
  git gh curl wget jq unzip \
  build-essential python3 python3-pip \
  htop ncdu tree

# 2) Docker permissions
sudo usermod -aG docker $USER
newgrp docker <<'EOF'
# 3) GitHub CLI auth (run manually after: gh auth login)
echo "Run 'gh auth login' manually after this script"
EOF

# 4) Self-hosted runner setup (run after gh auth)
cat > /tmp/setup-runner.sh <<'RUNNER'
#!/usr/bin/env bash
set -euo pipefail
REPO="YOUR_GITHUB_USER/free-cloud-stack"
RUNNER_DIR="/home/$USER/actions-runner"
mkdir -p "$RUNNER_DIR" && cd "$RUNNER_DIR"
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | sed 's/^v//')
curl -fsSL -o actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz \
  https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz
tar xzf actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz
./config.sh --url https://github.com/${REPO} --token $(gh api repos/${REPO}/actions/runners/registration-token --jq .token) --labels oracle-arm,free-tier --unattended
sudo ./svc.sh install
sudo ./svc.sh start
echo "Self-hosted runner installed and running"
RUNNER
chmod +x /tmp/setup-runner.sh
echo "To install self-hosted runner: /tmp/setup-runner.sh"

# 5) Keep-alive cron (prevent Oracle reclamation)
(crontab -l 2>/dev/null; echo "0 * * * * curl -fsS https://httpbin.org/get >/dev/null 2>&1") | crontab -
echo "Hourly keep-alive cron installed"

# 6) Cloudflare tunnel (optional - for exposing local services)
# cloudflared tunnel --url http://localhost:3000

echo "Oracle VM setup complete. Next steps:"
echo "  1) gh auth login"
echo "  2) /tmp/setup-runner.sh"
echo "  3) Reboot or newgrp docker"