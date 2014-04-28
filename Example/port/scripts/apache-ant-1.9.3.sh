#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=apache-ant
version=1.9.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.apache.org/dist/ant/source/apache-ant-1.9.3-src.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" apache-ant-1.9.3-src.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/jars,test-jar/jars/' build.xml

cp -v /usr/share/java/junit-4.11.jar lib/optional

./build.sh -Ddist.dir=/opt/ant-1.9.3 dist 
ln -v -sfn ant-1.9.3 /opt/ant


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
