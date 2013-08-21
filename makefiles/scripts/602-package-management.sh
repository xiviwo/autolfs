#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=package
version=
make
make install
./configure --prefix=/usr
make
