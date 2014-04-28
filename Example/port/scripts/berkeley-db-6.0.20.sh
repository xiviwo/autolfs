#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=berkeley-db
version=6.0.20
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.oracle.com/berkeley-db/db-6.0.20.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" db-6.0.20.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cd build_unix                        
../dist/configure --prefix=/usr --enable-compat185 --enable-dbm --disable-static --enable-cxx       
make

make docdir=/usr/share/doc/db-6.0.20 install 
chown -v -R root:root /usr/bin/db_* /usr/include/db{,_185,_cxx}.h /usr/lib/libdb*.{so,la} /usr/share/doc/db-6.0.20


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
