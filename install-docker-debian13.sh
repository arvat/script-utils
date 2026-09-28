#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

. /etc/os-release
if [ "${ID:-}" != "debian" ] || [ "${VERSION_CODENAME:-}" != "trixie" ]; then
  echo "Error: This script targets Debian 13 (trixie). Detected: ${PRETTY_NAME:-unknown}" >&2
  exit 1
fi

echo "Starting Docker installation for Debian 13 (Trixie)..."

echo "Removing any conflicting packages..."
for pkg in docker.io docker-doc docker-compose docker-buildx podman-docker containerd runc; do
  apt-get remove -y "$pkg" 2>/dev/null || true
done

echo "Installing prerequisites..."
apt-get update
apt-get install -y ca-certificates curl

echo "Adding Docker's GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "Setting up the Docker repository..."
rm -f /etc/apt/sources.list.d/docker.list
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "Installing Docker Engine and Compose..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Starting Docker service..."
systemctl enable --now docker

echo "Verifying installation..."
docker --version
docker compose version
docker run --rm hello-world

echo "Docker installation completed successfully!"
