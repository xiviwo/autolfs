#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=exim
version=4.82
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.exim.org/pub/exim/exim4/exim-4.82.tar.bz2
nwget http://ftp.exim.org/pub/exim/exim4/exim-4.82.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" exim-4.82.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 31 exim 
useradd -d /dev/null -c "Exim Daemon" -g exim -s /bin/false -u 31 exim

sed -e 's,^BIN_DIR.*$,BIN_DIRECTORY=/usr/sbin,' -e 's,^CONF.*$,CONFIGURE_FILE=/etc/exim.conf,' -e 's,^EXIM_USER.*$,EXIM_USER=exim,' -e 's,^EXIM_MONITOR,#EXIM_MONITOR,' src/EDITME > Local/Makefile 
echo -e "USE_GDBM = yes\nDBMLIB = -lgdbm" >> Local/Makefile 
make

make install 
install -v -m644 doc/exim.8 /usr/share/man/man8 
install -v -d -m755 /usr/share/doc/exim-4.82 
install -v -m644 doc/* /usr/share/doc/exim-4.82 
ln -sfv exim /usr/sbin/sendmail

cat >> /etc/aliases << "EOF"
postmaster: root
MAILER-DAEMON: root
EOF
exim -v -bi 
/usr/sbin/exim -bd -q15m

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-exim


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
