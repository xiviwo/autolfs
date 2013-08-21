#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=creating
version=
mkdir -v $LFS/tools
ln -sv $LFS/tools /
