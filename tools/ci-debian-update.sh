#!/bin/bash -x

echo "Acquire::http::Proxy \"http://192.168.1.10:3142\";" > /etc/apt/apt.conf.d/00aptproxy
apt-get update
apt-get dist-upgrade -yq
