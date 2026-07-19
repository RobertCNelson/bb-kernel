#!/bin/bash

cd /opt/linux-src/
git remote set-url origin https://forgejo.gfnd.rcn-ee.org:3000/kernel.org/mirror-linux-stable.git
git pull || true
sync
git gc --force --auto
cd -
