#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=stunnel
version=4.56
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.stunnel.org/stunnel/stunnel-4.56.tar.gz
nwget http://mirrors.zerg.biz/stunnel/stunnel-4.56.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" stunnel-4.56.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 51 stunnel 
useradd -c "stunnel Daemon" -d /var/lib/stunnel -g stunnel -s /bin/false -u 51 stunnel

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-fips 
make

make docdir=/usr/share/doc/stunnel-4.56 install

install -v -m750 -o stunnel -g stunnel -d /var/lib/stunnel/run 
chown stunnel:stunnel /var/lib/stunnel

cat >/etc/stunnel/stunnel.conf << "EOF" 
; File: /etc/stunnel/stunnel.conf

pid    = /run/stunnel.pid
chroot = /var/lib/stunnel
client = no
setuid = stunnel
setgid = stunnel
cert   = /etc/stunnel/stunnel.pem

EOF
chmod -v 644 /etc/stunnel/stunnel.conf

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-stunnel


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
