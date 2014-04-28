#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=procmail
version=3.22
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.ucsb.edu/pub/mirrors/procmail/procmail-3.22.tar.gz
nwget http://www.ring.gr.jp/archives/net/mail/procmail/procmail-3.22.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" procmail-3.22.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/getline/get_line/' src/*.[ch] 
make LOCKINGTEST=/tmp install 
make install-suid


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
