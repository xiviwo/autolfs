#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=nfs-utils
version=1.2.9
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/nfs/nfs-utils-1.2.9.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" nfs-utils-1.2.9.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 99 nogroup 
useradd -c "Unprivileged Nobody" -d /dev/null -g nogroup -s /bin/false -u 99 nobody

./configure --prefix=/usr --sysconfdir=/etc --without-tcp-wrappers --disable-nfsv4 --disable-gss 
make

make install

/home <192.168.0.0/24>(rw,subtree_check,anonuid=99,anongid=99)

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-nfs-server

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

cat > /etc/sysconfig/nfs-server << "EOF"
PORT="2049"
PROCESSES="8"
QUOTAS="no"
KILLDELAY="10"
EOF

<server-name>:/home  /home nfs   rw,_netdev,rsize=8192,wsize=8192 0 0
<server-name>:/usr   /usr  nfs   ro,_netdev,rsize=8192            0 0

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-nfs-client


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
