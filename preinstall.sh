#!/usr/bin/env bash
set -e

git clone https://github.com/sathanas65/deb13-i3
cd deb13-i3
bash install.sh 2>&1 | tee install.log
