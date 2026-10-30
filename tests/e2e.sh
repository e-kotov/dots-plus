#!/usr/bin/env bash
# Real install on Debian as an unprivileged user. Runs as root inside a throwaway container.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends python3 ca-certificates > /dev/null
useradd --create-home tester
cp -r /src /home/tester/src
chown -R tester /home/tester/src
cat > /home/tester/run.sh <<'SCRIPT'
set -euxo pipefail
export TSAPT_DIR="$HOME/.tsapt"
bash "$HOME/src/install.sh"
T="$TSAPT_DIR/bin"
grep -q '^TSAPT_PROXY=http://browser-proxy:8889$' "$TSAPT_DIR/tsapt.conf"
sed -i 's/^TSAPT_PROXY=.*/TSAPT_PROXY=off/' "$TSAPT_DIR/tsapt.conf"
"$T/tsapt" update
"$T/tsapt" install -y iperf3
"$T/tsapt" list | grep -q '^iperf3 '
if command -v iperf3; then exit 1; fi
"$T/tsrun" iperf3 --version
"$T/tsapt" remove iperf3
if "$T/tsrun" iperf3 --version; then exit 1; fi

# Plain names through the optional shell setup.
bash "$HOME/src/install.sh" --shell
bash "$HOME/src/install.sh" --shell
[ "$(grep -c '^# >>> dots-tsapt >>>$' "$HOME/.bashrc")" = 1 ]
[ "$(grep -c '^# >>> dots-tsapt >>>$' "$HOME/.profile")" = 1 ]
unset TSAPT_DIR
for shell_flag in -ic -lc; do
  bash "$shell_flag" '[ "$(command -v apt-get)" = "$HOME/.tsapt/shims/apt-get" ]'
  bash "$shell_flag" '[ -z "${LD_LIBRARY_PATH:-}" ]'
done
bash -ic 'apt update && apt-get install -y iperf3 && iperf3 --version && [ -z "${LD_LIBRARY_PATH:-}" ]'
bash -lc 'iperf3 --version && [ "$(command -v python3)" = /usr/bin/python3 ] && apt remove iperf3'
if bash -lc 'command -v iperf3'; then exit 1; fi
bash "$HOME/src/install.sh" --no-shell
if grep -q dots-tsapt "$HOME/.bashrc" "$HOME/.profile"; then exit 1; fi
SCRIPT
runuser -u tester -- bash /home/tester/run.sh
