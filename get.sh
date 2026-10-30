#!/usr/bin/env bash
# One-line install and update: fetch this release, then install it with the shell setup.
set -euo pipefail
TAG=v0.2.1
DIR="${TSAPT_SOURCE_DIR:-/workspace/shared/dots-tsapt}"
PROXY="${TSAPT_GET_PROXY-http://browser-proxy:8889}"
if [ -n "$PROXY" ]; then export HTTPS_PROXY="$PROXY" HTTP_PROXY="$PROXY"; fi
if [ -d "$DIR/.git" ]; then
  git -C "$DIR" fetch --quiet --force --depth 1 origin "refs/tags/$TAG:refs/tags/$TAG"
  git -C "$DIR" checkout --quiet "$TAG"
else
  git clone --quiet --depth 1 --branch "$TAG" https://github.com/e-kotov/dots-tsapt "$DIR"
fi
bash "$DIR/install.sh" --shell
