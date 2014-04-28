#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=dash
version=0.5.7
export MAKEFLAGS='-j 4'
download()
{
nwget http://gondor.apana.org.au/~herbert/dash/files/dash-0.5.7.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" dash-0.5.7.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --bindir=/bin --mandir=/usr/share/man 
make

make install

ln -svf dash /bin/sh

cat >> /etc/shells << "EOF"
/bin/dash
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
