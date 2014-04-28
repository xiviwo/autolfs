#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=junit
version=4.11
export MAKEFLAGS='-j 4'
download()
{
nwget http://hamcrest.googlecode.com/files/hamcrest-1.3.tgz
nwget https://launchpad.net/debian/+archive/primary/+files/junit4_4.11.orig.tar.gz
nwget http://anduin.linuxfromscratch.org/sources/other/junit-4.11.jar

}
unpack()
{
preparepack "$pkgname" "$version" junit4_4.11.orig.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
install -v -m755 -d /usr/share/java 
cp -v junit-4.11.jar /usr/share/java

tar -xf ../hamcrest-1.3.tgz                              
cp -v hamcrest-1.3/hamcrest-core-1.3{,-sources}.jar lib/ 
ant dist

install -v -m755 -d /usr/share/{doc,java}/junit-4.11 
chown -R root:root .                                 

cp -v -R junit*/javadoc/*             /usr/share/doc/junit-4.11  
cp -v junit*/junit*.jar               /usr/share/java/junit-4.11 
cp -v hamcrest-1.3/hamcrest-core*.jar /usr/share/java/junit-4.11

export CLASSPATH=$CLASSPATH:/usr/share/java/junit-4.11


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
