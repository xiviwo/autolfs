#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mailx
version=12.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/mailx-12.4-openssl_1.0.0_build_fix-1.patch
nwget http://downloads.sourceforge.net/heirloom/mailx-12.4.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" mailx-12.4.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../mailx-12.4-openssl_1.0.0_build_fix-1.patch 
make SENDMAIL=/usr/sbin/sendmail -j1

make PREFIX=/usr UCBINSTALL=/usr/bin/install install 
ln -v -sf mailx /usr/bin/mail 
ln -v -sf mailx /usr/bin/nail 
install -v -m755 -d /usr/share/doc/mailx-12.4 
install -v -m644 README mailx.1.html /usr/share/doc/mailx-12.4


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
