#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pulseaudio
version=4.0
export MAKEFLAGS='-j 1'
download()
{
nwget http://freedesktop.org/software/pulseaudio/releases/pulseaudio-4.0.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" pulseaudio-4.0.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 58 pulse 
groupadd -g 59 pulse-access 
useradd -c "Pulseaudio User" -d /var/run/pulse -g pulse -s /bin/false -u 58 pulse 
usermod -a -G audio pulse

find . -name "Makefile.in" | xargs sed -i "s|(libdir)/@PACKAGE@|(libdir)/pulse|" 
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-module-dir=/usr/lib/pulse/modules 
make

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
