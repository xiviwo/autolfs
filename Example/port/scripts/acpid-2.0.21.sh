#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=acpid
version=2.0.21
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/acpid2/acpid-2.0.21.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" acpid-2.0.21.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --docdir=/usr/share/doc/acpid-2.0.21 
make

make install                         
install -v -m755 -d /etc/acpi/events 
cp -r samples /usr/share/doc/acpid-2.0.21

cat > /etc/acpi/events/lid << "EOF"
event=button/lid
action=/etc/acpi/lid.sh
EOF

cat > /etc/acpi/lid.sh << "EOF"
#!/bin/sh
/bin/grep -q open /proc/acpi/button/lid/LID/state && exit 0
/usr/sbin/pm-suspend
EOF
chmod +x /etc/acpi/lid.sh

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-acpid


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
