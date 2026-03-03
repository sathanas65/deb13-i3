#!/usr/bin/env bash
set -e

git clone https://github.com/sathanas65/deb13-i3
mkdir -p deb12-i3
mv deb13-i3/install.sh deb12-i3/install.sh
cd deb12-i3
bash install.sh > install.log 2>&1
