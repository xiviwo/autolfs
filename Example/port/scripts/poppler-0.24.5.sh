#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=poppler
version=0.24.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://poppler.freedesktop.org/poppler-data-0.4.6.tar.gz
nwget http://poppler.freedesktop.org/poppler-0.24.5.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" poppler-0.24.5.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e "s:grep \"Qt 5\":grep \"Qt\\\|moc 5\":g" -e "s:QT_SELECT=qt5:QT_SELECT=5:" configure

./configure --prefix=/usr --sysconfdir=/etc --disable-static --enable-xpdf-headers 
make

make install 
install -v -m755 -d      /usr/share/doc/poppler-0.24.5 
install -v -m644 README* /usr/share/doc/poppler-0.24.5

tar -xf ../poppler-data-0.4.6.tar.gz 
cd poppler-data-0.4.6

make prefix=/usr install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
