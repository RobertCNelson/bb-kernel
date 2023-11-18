This is just a set of scripts to rebuild a known working kernel for ARM devices.

Script Bugs: "robertcnelson+bugs@gmail.com"

Note, for older git tag's please use: https://github.com/RobertCNelson/yakbuild

Dependencies: GCC Cross ToolChain

https://mirrors.edge.kernel.org/pub/tools/crosstool/

Dependencies: Linux Kernel Source

This git repo contains just scripts/patches to build a specific kernel for some
ARM devices. The kernel source will be downloaded when you run any of the build
scripts.

By default this script will clone the linux-stable tree:
https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
to: ${DIR}/ignore/linux-src:

If you've already cloned torvalds tree and would like to save some hard drive
space, just modify the LINUX_GIT variable in system.sh to point to your current
git clone directory.

Build Kernel Image:

```
./build_kernel.sh
```

Optional: Build Debian Package:

```
./build_deb.sh
```

Development/Hacking:

first run (to setup baseline tree):

```
./build_kernel.sh
```

then modify files under KERNEL directory
then run (to rebuild with your changes):

```
./tools/rebuild.sh
```

