#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=p7zip
version=9.20.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/p7zip/p7zip_9.20.1_src_all.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" p7zip_9.20.1_src_all.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e 's/chmod 555/chmod 755/' -e 's/chmod 444/chmod 644/' install.sh 
make all3

make DEST_HOME=/usr DEST_MAN=/usr/share/man DEST_SHARE_DOC=/usr/share/doc/p7zip-9.20.1 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
