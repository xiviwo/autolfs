#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=rsync
version=3.1.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://samba.org/ftp/rsync/src/rsync-3.1.0.tar.gz
nwget ftp://ftp.samba.org/pub/rsync/src/rsync-3.1.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" rsync-3.1.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 48 rsyncd 
useradd -c "rsyncd Daemon" -d /home/rsync -g rsyncd -s /bin/false -u 48 rsyncd

./configure --prefix=/usr --without-included-zlib 
make

make install

cat > /etc/rsyncd.conf << "EOF"
# This is a basic rsync configuration file
# It exports a single module without user authentication.

motd file = /home/rsync/welcome.msg
use chroot = yes

[localhost]
    path = /home/rsync
    comment = Default rsync module
    read only = yes
    list = yes
    uid = rsyncd
    gid = rsyncd

EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-rsyncd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
