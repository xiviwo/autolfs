#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=serf
version=1.3.4
export MAKEFLAGS='-j 4'
download()
{
nwget https://serf.googlecode.com/svn/src_releases/serf-1.3.4.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" serf-1.3.4.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "/Append/s:RPATH=libdir,::"   SConstruct 
sed -i "/Default/s:lib_static,::"    SConstruct 
sed -i "/Alias/s:install_static,::"  SConstruct 
scons PREFIX=/usr

scons PREFIX=/usr install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
