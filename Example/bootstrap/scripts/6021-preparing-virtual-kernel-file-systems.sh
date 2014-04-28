#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=preparing-virtual-kernel-file-systems
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
:
}
build()
{
mkdir -pv $LFS/{dev,proc,sys,run}

mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3

mount -v -t ext3 /dev/vdb1 $LFS/dev/shm)
fi

}
download;unpack;build
