#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libcap
version=2.24
export MAKEFLAGS='-j 4'
download()
{
nwget https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.24.tar.xz
nwget ftp://ftp.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.24.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libcap-2.24.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's:LIBDIR:PAM_&:g' pam_cap/Makefile 
make

sed -i '/install.*STALIBNAME/ s/^/#/' libcap/Makefile

make prefix=/usr SBINDIR=/sbin PAM_LIBDIR=/lib RAISE_SETFCAP=no install

chmod -v 755 /usr/lib/libcap.so 
mv -v /usr/lib/libcap.so.* /lib 
ln -sfv ../../lib/libcap.so.2 /usr/lib/libcap.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
