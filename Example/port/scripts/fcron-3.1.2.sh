#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=fcron
version=3.1.2
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.seul.org/pub/fcron/fcron-3.1.2.src.tar.gz
nwget http://fcron.free.fr/archives/fcron-3.1.2.src.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" fcron-3.1.2.src.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cat >> /etc/syslog.conf << "EOF"
# Begin fcron addition to /etc/syslog.conf

cron.* -/var/log/cron.log

# End fcron addition
EOF

/etc/rc.d/init.d/sysklogd reload

groupadd -g 22 fcron 
useradd -d /dev/null -c "Fcron User" -g fcron -s /bin/false -u 22 fcron

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --without-sendmail --with-boot-install=no 
make

make install

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-fcron


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
