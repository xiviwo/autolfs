#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libmusicbrainz
version=2.1.5
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.musicbrainz.org/pub/musicbrainz/historical/libmusicbrainz-2.1.5.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/libmusicbrainz-2.1.5-missing-includes-1.patch
nwget http://ftp.musicbrainz.org/pub/musicbrainz/historical/libmusicbrainz-2.1.5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libmusicbrainz-2.1.5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../libmusicbrainz-2.1.5-missing-includes-1.patch 
./configure --prefix=/usr 
make

(cd python && python setup.py build)

make install 
install -v -m644 -D docs/mb_howto.txt /usr/share/doc/libmusicbrainz-2.1.5/mb_howto.txt

(cd python && python setup.py install)


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
