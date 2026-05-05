#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

REPO_URL="https://github.com/MICHAEL2193/cloud-deploy-platform.git"
APP_DIR="/home/ec2-user/cloud-deploy-platform"
COMPOSE_VERSION="v2.39.2"
BUILDX_VERSION="v0.33.0"

dnf update -y
dnf install -y docker git curl

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

curl -SL "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64" \
  -o /usr/local/lib/docker/cli-plugins/docker-buildx
chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

until docker info >/dev/null 2>&1; do
  sleep 2
done

if [ -d "$APP_DIR/.git" ]; then
  cd "$APP_DIR"
  git fetch --all
  git reset --hard origin/main
else
  git clone "$REPO_URL" "$APP_DIR"
fi

chown -R ec2-user:ec2-user "$APP_DIR"

cd "$APP_DIR"
docker compose down --remove-orphans || true
docker compose up -d --build

for i in {1..30}; do
  if curl -fsS http://localhost/health; then
    echo
    echo "Application is healthy."
    break
  fi
  sleep 5
done