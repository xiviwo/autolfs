#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=intltool
version=0.50.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://launchpad.net/intltool/trunk/0.50.2/+download/intltool-0.50.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" intltool-0.50.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install 
install -v -m644 -D doc/I18N-HOWTO /usr/share/doc/intltool-0.50.2/I18N-HOWTO


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
