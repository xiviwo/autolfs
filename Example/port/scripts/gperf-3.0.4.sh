#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gperf
version=3.0.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnu.org/gnu/gperf/gperf-3.0.4.tar.gz
nwget ftp://ftp.gnu.org/gnu/gperf/gperf-3.0.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" gperf-3.0.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.0.4 
make

make install 

install -m644 -v doc/gperf.{dvi,ps,pdf} /usr/share/doc/gperf-3.0.4 

pushd /usr/share/info 
  rm -v dir 
  for FILENAME in *; do
    install-info $FILENAME dir 2>/dev/null
  done 
popd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
