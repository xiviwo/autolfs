#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=about-java
version=
export MAKEFLAGS='-j 4'
download()
{
nwget http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/OpenJDK-1.7.0.51-i686-bin.tar.xz
nwget http://anduin.linuxfromscratch.org/files/BLFS/OpenJDK-1.7.0.51/OpenJDK-1.7.0.51-x86_64-bin.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" OpenJDK-1.7.0.51-i686-bin.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
install -vdm755 /opt/OpenJDK-1.7.0.51-bin 
mv -v * /opt/OpenJDK-1.7.0.51-bin         
chown -R root:root /opt/OpenJDK-1.7.0.51-bin

export CLASSPATH=.:/usr/share/java 
export PATH="$PATH:/opt/OpenJDK-1.7.0.51-bin/bin"


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
