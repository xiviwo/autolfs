#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ntp
version=4.2.6p5
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/ntp-4.2.6p5.tar.gz
nwget http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.6p5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" ntp-4.2.6p5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 87 ntp 
useradd -c "Network Time Protocol" -d /var/lib/ntp -u 87 -g ntp -s /bin/false ntp

./configure --prefix=/usr --sysconfdir=/etc --enable-linuxcaps --with-binsubdir=sbin --with-lineeditlibs=readline 
make

make install 
install -v -o ntp -g ntp -d /var/lib/ntp 
install -v -m755 -d /usr/share/doc/ntp-4.2.6p5 
cp -v -R html/* /usr/share/doc/ntp-4.2.6p5/

cat > /etc/ntp.conf << "EOF"
# Asia
server 0.asia.pool.ntp.org

# Australia
server 0.oceania.pool.ntp.org

# Europe
server 0.europe.pool.ntp.org

# North America
server 0.north-america.pool.ntp.org

# South America
server 2.south-america.pool.ntp.org

driftfile /var/lib/ntp/ntp.drift
pidfile   /var/run/ntpd.pid
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-ntpd

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

ln -v -sf ../init.d/setclock /etc/rc.d/rc0.d/K46setclock 
ln -v -sf ../init.d/setclock /etc/rc.d/rc6.d/K46setclock


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
