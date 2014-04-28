#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=bazaar
version=2.5.1
export MAKEFLAGS='-j 4'
download()
{
nwget https://launchpad.net/bzr/2.5/2.5.1/+download/bzr-2.5.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" bzr-2.5.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e 's|man/man1|share/&|' setup.py 
python setup.py build

python setup.py install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
