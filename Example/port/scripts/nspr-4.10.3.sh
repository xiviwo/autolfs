#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=nspr
version=4.10.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v4.10.3/src/nspr-4.10.3.tar.gz
nwget ftp://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v4.10.3/src/nspr-4.10.3.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" nspr-4.10.3.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cd nspr                                                     
sed -ri 's#^(RELEASE_BINS =).*#\1#' pr/src/misc/Makefile.in 
sed -i 's#$(LIBRARY) ##' config/rules.mk                    

./configure --prefix=/usr --with-mozilla --with-pthreads $([ $(uname -m) = x86_64 ] && echo --enable-64bit) 
make

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
