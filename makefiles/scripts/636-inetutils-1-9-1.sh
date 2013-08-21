#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=inetutils
version=1.9.1
echo "Building -------------- inetutils-1.9.1--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf inetutils-1.9.1.tar.gz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
sed -i -e '/gets is a/d' lib/stdio.in.h
./configure --prefix=/usr  \
    --libexecdir=/usr/sbin \
    --localstatedir=/var   \
    --disable-ifconfig     \
    --disable-logger       \
    --disable-syslogd      \
    --disable-whois        \
    --disable-servers
make
make install
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
echo "End of Building -------------- inetutils-1.9.1--------------"
