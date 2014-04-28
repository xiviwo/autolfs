#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=adding-the-lfs-user
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
	groupadd lfs || true
useradd -s /bin/bash -g lfs -m -k /dev/null lfs || true

echo 'lfs:ping' | chpasswd

chown -Rv lfs $LFS/tools

chown -Rv lfs $LFS/sources



}
download;unpack;build
