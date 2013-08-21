#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=configuring
version=
echo "HOSTNAME=	<lfs>" > /etc/sysconfig/network
