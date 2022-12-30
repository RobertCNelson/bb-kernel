#!/bin/sh -e
#
# Copyright (c) 2012 Robert Nelson <robertcnelson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

DIR=$PWD

if [ ! -f "${DIR}/patches/bisect_defconfig" ] ; then
	cp "${DIR}/patches/defconfig" "${DIR}/patches/bisect_defconfig"
fi

cp -v "${DIR}/patches/bisect_defconfig" "${DIR}/patches/defconfig"

cd "${DIR}/KERNEL/" || exit
git bisect start
#git bisect good d18b78abc0c6e7d3119367c931c583e02d466495
#git bisect bad f6d5cb9e2c06f7d583dd9f4f7cca21d13d78c32a
#git bisect bad 6afcb8b93400b774f3d74df7e1fc63805cbc92b3
#git bisect bad 1c263d0e54f4348df126e4c3c1011253d7651544
#git bisect good 76c38196391b9a33894e0af8465dcef65e8deeab
#git bisect good c666936d8d8b0ace4f3260d71a4eedefd53011d9
#git bisect good 402ff143b90b48c1d1b29127fa538a2d227c2161

git describe
cd "${DIR}/" || exit
