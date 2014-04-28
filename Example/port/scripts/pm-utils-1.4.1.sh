#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pm-utils
version=1.4.1
export MAKEFLAGS='-j 1'
download()
{
nwget http://pm-utils.freedesktop.org/releases/pm-utils-1.4.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" pm-utils-1.4.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/pm-utils-1.4.1 
make
sed -i 's/ln -s pm-action.8/ln -svf pm-action.8/p' man/Makefile
make install

#install -v -m644 man/*.1 /usr/share/man/man1 
#install -v -m644 man/*.8 /usr/share/man/man8 
#ln -svf pm-action.8 /usr/share/man/man8/pm-suspend.8 
#ln -sv pm-action.8 /usr/share/man/man8/pm-hibernate.8 
#l#n -sv pm-action.8 /usr/share/man/man8/pm-suspend-hybrid.8


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
