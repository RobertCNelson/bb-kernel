#!/bin/bash -x

pip3 install --break-system-packages --root-user-action=ignore git+https://forgejo.gfnd.rcn-ee.org:3000/mirror/dt-schema.git@main
dt-validate --version
sed -i -e 's:#DTBS_CHECK=1:DTBS_CHECK=1:g' system.sh.gitlab
