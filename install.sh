#!/usr/bin/env bash
# Copy tsapt and tsrun into a directory. Touches no system files. Changes shell startup files
# only with --shell, and --no-shell undoes that.
set -euo pipefail
SOURCE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEST="${TSAPT_DIR:-/workspace/shared/.tsapt}"
MODE="${1:-}"
case "$MODE" in ""|--shell|--no-shell) ;; *) echo "usage: install.sh [--shell|--no-shell]" >&2; exit 2 ;; esac
[[ "$DEST" = /* && "$DEST" != *[[:space:]\|\&]* ]] || { echo "TSAPT_DIR must be an absolute path without spaces" >&2; exit 1; }
BEGIN="# >>> dots-plus >>>"
END="# <<< dots-plus <<<"

remove_block() {
  [ -f "$1" ] || return 0
  sed -i "/^$BEGIN\$/,/^$END\$/d" "$1"
  # Blocks written before the project was renamed.
  sed -i "/^# >>> dots-tsapt >>>\$/,/^# <<< dots-tsapt <<<\$/d" "$1"
}

if [ "$MODE" = --no-shell ]; then
  remove_block "$HOME/.bashrc"
  remove_block "$HOME/.profile"
  echo "Removed the dots-plus lines from your shell startup files."
  exit 0
fi

for tool in python3 apt-get apt-cache dpkg dpkg-deb; do
  command -v "$tool" > /dev/null || { echo "missing required tool: $tool" >&2; exit 1; }
done
mkdir -p "$DEST/bin" "$DEST/shims" "$DEST/path"
install -m 755 "$SOURCE/bin/tsapt" "$SOURCE/bin/tsrun" "$DEST/bin/"
install -m 644 "$SOURCE/VERSION" "$DEST/VERSION"
sed "s|__TSAPT_DIR__|$DEST|" "$SOURCE/env.sh" > "$DEST/env.sh"
for name in apt apt-get apt-cache; do ln -sfn ../bin/tsapt "$DEST/shims/$name"; done
if [ ! -e "$DEST/tsapt.conf" ]; then
  printf '# Proxy for apt downloads, or "off" for a direct connection.\nTSAPT_PROXY=http://browser-proxy:8889\n' \
    > "$DEST/tsapt.conf"
fi
echo "Installed to $DEST"

if [ "$MODE" = --shell ]; then
  block="$BEGIN
[ -f \"$DEST/env.sh\" ] && . \"$DEST/env.sh\"
$END"
  # At the top of .bashrc, because the usual early exit for non-interactive shells would skip it lower down.
  remove_block "$HOME/.bashrc"
  { printf '%s\n' "$block"; [ ! -f "$HOME/.bashrc" ] || cat "$HOME/.bashrc"; } > "$HOME/.bashrc.tsapt-new"
  cat "$HOME/.bashrc.tsapt-new" > "$HOME/.bashrc"
  rm -f "$HOME/.bashrc.tsapt-new"
  remove_block "$HOME/.profile"
  printf '%s\n' "$block" >> "$HOME/.profile"
  echo "Open a new shell, then use apt and installed programs by their plain names."
else
  echo "  $DEST/bin/tsapt install -y <package>"
  echo "  $DEST/bin/tsrun <program>"
  echo "For plain apt and program names, run: bash install.sh --shell"
fi
