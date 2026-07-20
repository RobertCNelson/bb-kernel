#!/bin/bash

tar --zstd -xf ccache.tar.zst -C / || true
df -h /dev/shm
ccache -M 5G
ccache -sv
ccache -z
