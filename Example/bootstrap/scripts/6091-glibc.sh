#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=glibc
version=2.19
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" glibc-2.19.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/\\$$(pwd)/`pwd`/' timezone/Makefile

patch -Np1 -i ../glibc-2.19-fhs-1.patch

mkdir -pv ../glibc-build
cd ../glibc-build

../glibc-2.19/configure --prefix=/usr --disable-profile --enable-kernel=2.6.32 --enable-obsolete-rpc

make

 2>&1 | tee 
grep Error 

touch /etc/ld.so.conf

make install

cp -v ../glibc-2.19/nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

mkdir -pv /usr/lib/locale
 -i cs_CZ -f UTF-8 cs_CZ.UTF-8
 -i de_DE -f ISO-8859-1 de_DE
 -i de_DE@euro -f ISO-8859-15 de_DE@euro
 -i de_DE -f UTF-8 de_DE.UTF-8
 -i en_GB -f UTF-8 en_GB.UTF-8
 -i en_HK -f ISO-8859-1 en_HK
 -i en_PH -f ISO-8859-1 en_PH
 -i en_US -f ISO-8859-1 en_US
 -i en_US -f UTF-8 en_US.UTF-8
 -i es_MX -f ISO-8859-1 es_MX
 -i fa_IR -f UTF-8 fa_IR
 -i fr_FR -f ISO-8859-1 fr_FR
 -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
 -i fr_FR -f UTF-8 fr_FR.UTF-8
 -i it_IT -f ISO-8859-1 it_IT
 -i it_IT -f UTF-8 it_IT.UTF-8
 -i ja_JP -f EUC-JP ja_JP
 -i ru_RU -f KOI8-R ru_RU.KOI8-R
 -i ru_RU -f UTF-8 ru_RU.UTF-8
 -i tr_TR -f UTF-8 tr_TR.UTF-8
 -i zh_CN -f GB18030 zh_CN.GB18030

make localedata/install-locales

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../tzdata2013i.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO



cp -v /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
