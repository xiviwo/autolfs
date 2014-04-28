#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lsb-release
version=1.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://sourceforge.net/projects/lsb/files/lsb_release/1.4/lsb-release-1.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" lsb-release-1.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "s|n/a|unavailable|" lsb_release

./help2man -N --include ./lsb_release.examples --alt_version_key=program_version ./lsb_release > lsb_release.1

install -v -m 644 lsb_release.1 /usr/share/man/man1/lsb_release.1 
install -v -m 755 lsb_release /usr/bin/lsb_release


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
