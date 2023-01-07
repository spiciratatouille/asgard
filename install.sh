#!/usr/bin/env sh
set -eu

echo "We need your sudo password to install the script."
echo "You can check the script in https://gitlab.com/rogs/yams/-/blob/master/setup.sh"

sudo rm -r /tmp/yams || true
git clone https://gitlab.com/rogs/yams.git /tmp/yams
sudo bash /tmp/yams/setup.sh
