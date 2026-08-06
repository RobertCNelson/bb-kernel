#!/bin/sh -e

# SPDX-FileCopyrightText: 2009 Robert Nelson <robertcnelson@gmail.com>
#
# SPDX-License-Identifier: MIT

DIR=$PWD

CORES=$(getconf _NPROCESSORS_ONLN)
debian_stable_git="2.20.1"
#git hard requirements:
#git: --local
#git: --list
#git: --no-edit
#git: --no-rebase

git_is_old () {
	echo "-----------------------------"
	echo "scripts/git: git is too old: [`LC_ALL=C ${git_bin} --version | awk '{print $3}'`]; Please Install atleast [${debian_stable_git}] [https://git-scm.com/]"
	echo "-----------------------------"
	exit 2
}

check_git_version () {
	git_major=$(LC_ALL=C ${git_bin} --version | awk '{print $3}' | cut -d. -f1)
	git_minor=$(LC_ALL=C ${git_bin} --version | awk '{print $3}' | cut -d. -f2)
	git_sub=$(LC_ALL=C ${git_bin} --version | awk '{print $3}' | cut -d. -f3)

	#debian Stable:
	#https://packages.debian.org/stretch/git (9) -> 2.11.0
	#https://packages.debian.org/buster/git (10) -> 2.20.1
	#https://packages.debian.org/bullseye/git (11) -> 2.30.2
	#https://packages.debian.org/bookworm/git (12) -> 2.39.5
	#https://packages.ubuntu.com/bionic/git (18.04) -> 2.17.1
	#https://packages.ubuntu.com/focal/git (20.04) -> 2.25.1
	#https://packages.ubuntu.com/jammy/git (22.04) -> 2.34.1
	#https://packages.ubuntu.com/noble/git (24.04) -> 2.43.0

	compare_major="2"
	compare_minor="20"
	compare_sub="1"

	if [ "${git_major}" -lt "${compare_major}" ] ; then
		git_is_old
	elif [ "${git_major}" -eq "${compare_major}" ] ; then
		if [ "${git_minor}" -lt "${compare_minor}" ] ; then
			git_is_old
		elif [ "${git_minor}" -eq "${compare_minor}" ] ; then
			if [ "${git_sub}" -lt "${compare_sub}" ] ; then
				git_is_old
			fi
		fi
	fi

	echo "scripts/git: [`LC_ALL=C ${git_bin} --version`]"
}

check_git_identity() {
	missing=""

	# Check user.name
	if [ -z "$(${git_bin} config user.name)" ]; then
		missing="user.name"
	fi

	# Check user.email
	if [ -z "$(${git_bin} config user.email)" ]; then
		if [ -n "$missing" ]; then
			missing="$missing user.email"
		else
			missing="user.email"
		fi
	fi

	if [ -n "$missing" ]; then
		echo "Error: Missing Git configuration: $missing" >&2
		echo "Please set them using:" >&2
		echo "  git config --global user.name \"Your Name\"" >&2
		echo "  git config --global user.email \"you@example.com\"" >&2
		exit 1
	fi
}

git_kernel_org_stable_tag_backup () {
	#We want to hit git.kernel.org last for least bandwidth hit...
	backup_stable_repo="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"
	echo "-----------------------------"
	echo "scripts/git: fetching v${KERNEL_TAG} from: ${backup_stable_repo}"
	${git_bin} fetch "${backup_stable_repo}" tag v${KERNEL_TAG} --no-tags
}

git_kernel_stable_tag_backup () {
	backup_stable_repo="https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git"
	echo "-----------------------------"
	echo "scripts/git: fetching v${KERNEL_TAG} from: ${backup_stable_repo}"
	${git_bin} fetch "${backup_stable_repo}" tag v${KERNEL_TAG} --no-tags || git_kernel_org_stable_tag_backup
}

git_kernel_stable_tag () {
	echo "-----------------------------"
	echo "scripts/git: fetching v${KERNEL_TAG} from: ${linux_stable_repo}"
	${git_bin} fetch "${linux_stable_repo}" tag v${KERNEL_TAG} --no-tags || git_kernel_stable_tag_backup
}

check_and_or_clone () {
	#For Legacy: moving to "${DIR}/ignore/linux-src/" for all new installs
	if [ ! "${LINUX_GIT}" ] && [ -f "${HOME}/linux-src/.git/config" ] ; then
		LINUX_GIT="${HOME}/linux-src"
	fi

	if [ ! "${LINUX_GIT}" ]; then
		if [ -f "${DIR}/ignore/linux-src/.git/config" ] ; then
			echo "-----------------------------"
			echo "scripts/git: LINUX_GIT not defined in system.sh"
			echo "using default location: ${DIR}/ignore/linux-src/"
		else
			echo "-----------------------------"
			echo "scripts/git: LINUX_GIT not defined in system.sh"
			echo "cloning ${linux_repo} into default location: ${DIR}/ignore/linux-src"
			${git_bin} clone "${linux_repo}" "${DIR}/ignore/linux-src"
		fi
		LINUX_GIT="${DIR}/ignore/linux-src"
	fi
}

git_kernel () {
	check_and_or_clone

	#In the past some users set LINUX_GIT = DIR, fix that...
	if [ -f "${LINUX_GIT}/version.sh" ] ; then
		unset LINUX_GIT
		echo "-----------------------------"
		echo "scripts/git: Warning: LINUX_GIT is set as DIR:"
		check_and_or_clone
	fi

	#is the git directory user writable?
	if [ ! -w "${LINUX_GIT}" ] ; then
		unset LINUX_GIT
		echo "-----------------------------"
		echo "scripts/git: Warning: LINUX_GIT is not writable:"
		check_and_or_clone
	fi

	#is it actually a git repo?
	if [ ! -f "${LINUX_GIT}/.git/config" ] ; then
		unset LINUX_GIT
		echo "-----------------------------"
		echo "scripts/git: Warning: LINUX_GIT is an invalid tree:"
		check_and_or_clone
	fi

	cd "${LINUX_GIT}/" || exit
	echo "-----------------------------"
	echo "scripts/git: Debug: LINUX_GIT is setup as: [${LINUX_GIT}]."
	echo "scripts/git: [$(cat .git/config | grep url | sed 's/\t//g' | sed 's/ //g')]"
	if [ ! "${SHARED_GIT}" ] ; then
		echo "scripts/git: LINUX_GIT: fetch --tags"
		${git_bin} fetch --tags || true
	else
		echo "scripts/git: LINUX_GIT fetch disabled via SHARED_GIT variable"
	fi
	echo "-----------------------------"
	cd "${DIR}/" || exit

	if [ ! -f "${DIR}/KERNEL/.git/config" ] ; then
		rm -rf "${DIR}/KERNEL/" || true
		${git_bin} clone --shared "${LINUX_GIT}" "${DIR}/KERNEL"
	fi

	#Automaticly, just recover the git repo from a git crash
	if [ -f "${DIR}/KERNEL/.git/index.lock" ] ; then
		rm -rf "${DIR}/KERNEL/" || true
		${git_bin} clone --shared "${LINUX_GIT}" "${DIR}/KERNEL"
	fi

	cd "${DIR}/KERNEL/" || exit

	if [ "${RUN_BISECT}" ] ; then
		${git_bin} bisect reset || true
	fi

	${git_bin} am --abort 2>/dev/null || true
	${git_bin} reset --hard HEAD
	${git_bin} clean -fd
	${git_bin} checkout master -f

	echo "log: [${git_bin} pull --no-rebase --no-edit]"
	${git_bin} pull --no-rebase --no-edit || true

	${git_bin} rev-parse --verify "refs/tags/v${KERNEL_TAG}" >/dev/null 2>&1 || git_kernel_stable_tag

	target_branch="v${KERNEL_TAG}${BUILD}"

	if ${git_bin} show-ref --verify --quiet "refs/heads/${target_branch}"; then
		echo "scripts/git: Deleting existing local branch ${target_branch}"
		${git_bin} branch -D "${target_branch}"
	fi

	echo "scripts/git: Checking out ${KERNEL_TAG} into ${target_branch}"
	${git_bin} checkout "v${KERNEL_TAG}" -b "${target_branch}"

	${git_bin} describe

	cd "${DIR}/" || exit
}

git_shallow_fail () {
	echo "Sorry, ${kernel_tag} is not in git, trying via patch"
	old_kernel=$(echo ${kernel_tag} | awk -F'-' '{print $1}')

	echo "git: [git clone -b v${old_kernel} https://github.com/RobertCNelson/linux-stable-rcn-ee]"
	${git_bin} clone --depth=1 -b v${old_kernel} https://github.com/RobertCNelson/linux-stable-rcn-ee "${DIR}/KERNEL/"

	if [ -d "${DIR}/KERNEL/" ] ; then
		cd "${DIR}/KERNEL/"

		if [ -f patch-${kernel_tag}.diff.gz ] ; then
			rm -f patch-${kernel_tag}.diff.gz || true
		fi

		wget https://rcn-ee.com/deb/sid-armhf/v${kernel_tag}/patch-${kernel_tag}.diff.gz

		if [ -f patch-${kernel_tag}.diff.gz ] ; then
			zcat patch-${kernel_tag}.diff.gz | ${git_bin} apply -v
			rm -f patch-${kernel_tag}.diff.gz || true

			if [ -f defconfig ] ; then
				rm -f defconfig || true
			fi

			wget https://rcn-ee.com/deb/sid-armhf/v${kernel_tag}/defconfig
			mv defconfig arch/arm/configs/rcn-ee_defconfig

			${git_bin} add --all
			${git_bin} commit --allow-empty -a -m "${kernel_tag} patchset"
			cd "${DIR}"
		else
			echo "Sorry, unable to find kernel patch"
			cd "${DIR}"
			exit 2
		fi
	fi
}

git_shallow () {
	if [ "x${kernel_tag}" = "x" ] ; then
		echo "error: set kernel_tag in recipe.sh"
		exit 2
	fi
	if [ ! -f "${DIR}/KERNEL/.ignore-${kernel_tag}" ] ; then
		if [ -d "${DIR}/KERNEL/" ] ; then
			rm -rf "${DIR}/KERNEL/" || true
		fi
		mkdir "${DIR}/KERNEL/" || true
		echo "git: [git clone -b ${kernel_tag} https://github.com/RobertCNelson/linux-stable-rcn-ee]"
		${git_bin} clone --depth=10 -b ${kernel_tag} https://github.com/RobertCNelson/linux-stable-rcn-ee "${DIR}/KERNEL/" || git_shallow_fail
		touch "${DIR}/KERNEL/.ignore-${kernel_tag}"
	fi
}

. "${DIR}/version.sh"
. "${DIR}/system.sh"

if [ "${USE_LOCAL_GIT_MIRROR}" ] ; then
	linux_repo="https://forgejo.gfnd.rcn-ee.org:3000/kernel.org/mirror-linux-stable.git"
	linux_stable_repo="https://forgejo.gfnd.rcn-ee.org:3000/kernel.org/mirror-linux-stable.git"
fi

git_bin=$(which git)
check_git_version
check_git_identity

if [ ! -f "${DIR}/.yakbuild" ] ; then
	git_kernel
else
	. "${DIR}/recipe.sh"
	git_shallow
fi

#
