#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mercurial
version=2.9
export MAKEFLAGS='-j 4'
download()
{
nwget http://mercurial.selenic.com/release/mercurial-2.9.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" mercurial-2.9.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make build

make doc

make PREFIX=/usr install-bin

cat >> ~/.hgrc << "EOF"
[ui]
username = <user_name> <your@mail>
EOF

install -v -d -m755 /etc/mercurial 
cat > /etc/mercurial/hgrc << "EOF"
[web]
cacerts = /etc/ssl/ca-bundle.crt
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
