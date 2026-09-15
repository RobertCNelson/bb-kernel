#!/bin/bash -x

if [ ! -f /opt/linux-src/.git/logs/HEAD.lock ] ; then
	if [ ! -f /opt/linux-src/.git/logs/refs/heads/master.lock ] ; then
		cd /opt/linux-src/
		git remote set-url origin https://forgejo.gfnd.rcn-ee.org:3000/kernel.org/mirror-linux-stable.git
		git pull || true
		sync
		git gc --force --auto
		cd -
	else
		echo "log: ci-git.sh disabled as /opt/linux-src/.git/logs/refs/heads/master.lock exits"
	fi
else
	echo "log: ci-git.sh disabled as /opt/linux-src/.git/logs/HEAD.lock exits"
fi
