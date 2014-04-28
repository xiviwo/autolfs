#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pyxdg
version=0.25
export MAKEFLAGS='-j 4'
download()
{
nwget http://people.freedesktop.org/~takluyver/pyxdg-0.25.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" pyxdg-0.25.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
python setup.py install --optimize=1

python3 setup.py install --optimize=1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
