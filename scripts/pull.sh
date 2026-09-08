#!/bin/bash

# SPDX-FileCopyrightText: Robert Nelson <robertcnelson@gmail.com>
# SPDX-License-Identifier: MIT

BRANCH="am33x-v6.18"
REPO="bb-kernel"

git pull --no-edit https://github.com/RobertCNelson/${REPO}.git ${BRANCH}
git pull --no-edit https://gitlab.com/RobertCNelson/${REPO}.git ${BRANCH}
