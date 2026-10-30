#!/usr/bin/env bash
# Copy tsapt and tsrun into a directory. Changes nothing else: no shell profile, no system files.
set -euo pipefail
SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${TSAPT_DIR:-/workspace/shared/.tsapt}"
[[ "$DEST" = /* ]] || { echo "TSAPT_DIR must be an absolute path" >&2; exit 1; }
for tool in python3 apt-get apt-cache dpkg dpkg-deb; do
  command -v "$tool" > /dev/null || { echo "missing required tool: $tool" >&2; exit 1; }
done
mkdir -p "$DEST/bin"
install -m 755 "$SOURCE/bin/tsapt" "$SOURCE/bin/tsrun" "$DEST/bin/"
install -m 644 "$SOURCE/VERSION" "$DEST/VERSION"
if [ ! -e "$DEST/tsapt.conf" ]; then
  printf '# Proxy for apt downloads, or "off" for a direct connection.\nTSAPT_PROXY=http://browser-proxy:8889\n' \
    > "$DEST/tsapt.conf"
fi
echo "Installed to $DEST"
echo "  $DEST/bin/tsapt update"
echo "  $DEST/bin/tsapt install -y <package>"
echo "  $DEST/bin/tsrun <program>"
