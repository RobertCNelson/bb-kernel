#!/bin/bash

ccache -sv
df -h /dev/shm
tar --use-compress-program='zstd -6' -cf ccache.tar.zst /dev/shm/my-ccache-in-memory
