#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=icedtea-web
version=1.4.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://icedtea.classpath.org/download/source/icedtea-web-1.4.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" icedtea-web-1.4.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=${JAVA_HOME}/jre --with-jdk-home=${JAVA_HOME} --disable-docs --mandir=${JAVA_HOME}/man 
make

make install 
mandb -c /opt/jdk/man

ln -svf ${JAVA_HOME}/jre/lib/IcedTeaPlugin.so /usr/lib/mozilla/plugins/


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
