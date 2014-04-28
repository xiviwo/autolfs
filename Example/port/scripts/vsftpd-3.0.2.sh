#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=vsftpd
version=3.0.2
export MAKEFLAGS='-j 4'
download()
{
nwget https://security.appspot.com/downloads/vsftpd-3.0.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" vsftpd-3.0.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
install -v -d -m 0755 /usr/share/vsftpd/empty 
install -v -d -m 0755 /home/ftp               
groupadd -g 47 vsftpd                         
groupadd -g 45 ftp                            

useradd -c "vsftpd User"  -d /dev/null -g vsftpd -s /bin/false -u 47 vsftpd 
useradd -c anonymous_user -d /home/ftp -g ftp    -s /bin/false -u 45 ftp

sed -i -e 's|#define VSF_SYSDEP_HAVE_LIBCAP|//&|' sysdeputil.c

make

install -v -m 755 vsftpd        /usr/sbin/vsftpd    
install -v -m 644 vsftpd.8      /usr/share/man/man8 
install -v -m 644 vsftpd.conf.5 /usr/share/man/man5 
install -v -m 644 vsftpd.conf   /etc

cat >> /etc/vsftpd.conf << "EOF"
background=YES
listen=YES
nopriv_user=vsftpd
secure_chroot_dir=/usr/share/vsftpd/empty
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-vsftpd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
