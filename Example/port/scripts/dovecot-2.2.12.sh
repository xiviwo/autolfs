#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=dovecot
version=2.2.12
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.dovecot.org/releases/2.2/dovecot-2.2.12.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" dovecot-2.2.12.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 42 dovecot 
useradd -c "Dovecot unprivileged user" -d /dev/null -u 42 -g dovecot -s /bin/false dovecot 
groupadd -g 43 dovenull 
useradd -c "Dovecot login user" -d /dev/null -u 43 -g dovenull -s /bin/false dovenull

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --docdir=/usr/share/doc/dovecot-2.2.12 --disable-static 
make

make install

cp -rv /usr/share/doc/dovecot-2.2.12/example-config/* /etc/dovecot

sed -i '/^\!include / s/^/#/' /etc/dovecot/dovecot.conf 
chmod -v 1777 /var/mail 
cat > /etc/dovecot/local.conf << "EOF"
protocols = imap
ssl = no
# The next line is only needed if you have no IPv6 network interfaces
listen = *
mail_location = mbox:~/Mail:INBOX=/var/mail/%u
userdb {
  driver = passwd
}
passdb {
  driver = shadow
}
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-dovecot


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
