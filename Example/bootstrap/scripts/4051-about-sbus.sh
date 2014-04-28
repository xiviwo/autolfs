#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=about-sbus
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




}
download;unpack;build
