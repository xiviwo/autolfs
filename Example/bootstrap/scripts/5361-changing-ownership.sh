#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=changing-ownership
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
chown -R root:root $LFS/tools

}
download;unpack;build
