#!/usr/bin/env bash
# Optional. Install a pinned dots-tailscale release, unmodified, under /workspace/shared.
# It does not sign in to Tailscale and it installs nothing from this repository.
set -euo pipefail
TAG=v0.8.0
COMMIT=a54688e1e2814ed89e9a219c62d7398398b855cd
SOURCE_DIR="${DOTS_TS_SOURCE_DIR:-/workspace/shared/dots-tailscale}"
export DOTS_TS_DIR="${DOTS_TS_DIR:-/workspace/shared/.dots-tailscale}"
PROXY="${UPSTREAM_PROXY:-http://browser-proxy:8889}"
if [ ! -e "$SOURCE_DIR" ]; then
  HTTPS_PROXY="$PROXY" HTTP_PROXY="$PROXY" \
    git clone --quiet --depth 1 --branch "$TAG" https://github.com/abruption/dots-tailscale "$SOURCE_DIR"
fi
actual="$(git -C "$SOURCE_DIR" rev-parse HEAD)"
if [ "$actual" != "$COMMIT" ]; then
  echo "dots-tailscale is at $actual, expected $COMMIT. Stopping." >&2
  exit 1
fi
bash "$SOURCE_DIR/tailscale-setup.sh" install
echo "dots-tailscale $TAG installed in $DOTS_TS_DIR. Not signed in yet."
