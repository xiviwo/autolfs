#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lsof
version=4.87
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://sunsite.ualberta.ca/pub/Mirror/lsof/lsof_4.87.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" lsof_4.87.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf lsof_4.87_src.tar  
cd lsof_4.87_src           
./Configure -n linux       
make CFGL="-L./lib -ltirpc"

install -v -m0755 -o root -g root lsof /usr/bin 
install -v lsof.8 /usr/share/man/man8


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
