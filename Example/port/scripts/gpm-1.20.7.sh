#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gpm
version=1.20.7
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.nico.schottelius.org/software/gpm/archives/gpm-1.20.7.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" gpm-1.20.7.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./autogen.sh                                
./configure --prefix=/usr --sysconfdir=/etc 
make

make install                                          

install-info --dir-file=/usr/share/info/dir /usr/share/info/gpm.info                 

ln -sfv libgpm.so.2.1.0 /usr/lib/libgpm.so            
install -v -m644 conf/gpm-root.conf /etc              

install -v -m755 -d /usr/share/doc/gpm-1.20.7/support 
install -v -m644    doc/support/* /usr/share/doc/gpm-1.20.7/support 
install -v -m644    doc/{FAQ,HACK_GPM,README*} /usr/share/doc/gpm-1.20.7

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-gpm

cat > /etc/sysconfig/mouse << "EOF"
# Begin /etc/sysconfig/mouse

MDEVICE="<yourdevice>"
PROTOCOL="<yourprotocol>"
GPMOPTS="<additional options>"

# End /etc/sysconfig/mouse
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
