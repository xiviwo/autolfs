#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=scons
version=2.3.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/scons/scons-2.3.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" scons-2.3.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
python setup.py install --prefix=/usr --standard-lib --optimize=1 --install-data=/usr/share


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
