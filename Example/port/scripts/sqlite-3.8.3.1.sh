#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sqlite
version=3.8.3.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://sqlite.org/2014/sqlite-autoconf-3080301.tar.gz
nwget http://sqlite.org/2014/sqlite-doc-3080301.zip

}
unpack()
{
preparepack "$pkgname" "$version" sqlite-autoconf-3080301.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
unzip -q ../sqlite-doc-3080301.zip

./configure --prefix=/usr --disable-static CFLAGS="-g -O2 -DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_UNLOCK_NOTIFY=1 -DSQLITE_SECURE_DELETE=1" 
make

make install

install -v -m755 -d /usr/share/doc/sqlite-3.8.3.1 
cp -v -R sqlite-doc-3080301/* /usr/share/doc/sqlite-3.8.3.1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
