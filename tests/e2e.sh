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
! command -v iperf3
"$T/tsrun" iperf3 --version
"$T/tsapt" remove iperf3
! "$T/tsrun" iperf3 --version
SCRIPT
runuser -u tester -- bash /home/tester/run.sh
