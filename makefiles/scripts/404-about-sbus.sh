#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=about
version=
export MAKEFLAGS='-j 2'
make -j2
