#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=install-tl-unx
version=
export MAKEFLAGS='-j 4'
download()
{
nwget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" install-tl-unx.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf install-tl-unx.tar.gz 
cd install-tl-<CCYYMMDD> 

TEXLIVE_INSTALL_PREFIX=/opt/texlive ./install-tl

cat >> /etc/profile.d/extrapaths.sh << "EOF"
pathappend /usr/share/man                        MANPATH
pathappend /opt/texlive/2013/texmf-dist/doc/man  MANPATH
pathappend /usr/share/info                       INFOPATH
pathappend /opt/texlive/2013/texmf-dist/doc/info INFOPATH
pathappend /opt/texlive/2013/bin/x86_64-linux
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
