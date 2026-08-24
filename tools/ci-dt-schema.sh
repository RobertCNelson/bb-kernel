#!/bin/bash -x

pipx install git+https://forgejo.gfnd.rcn-ee.org:3000/mirror/dt-schema.git@main

if dt-validate --version; then
	sed -i -e 's:#DTBS_CHECK=1:DTBS_CHECK=1:g' system.sh.gitlab
else
	echo "Validation FAILED. Skipping system.sh.gitlab update."
fi
