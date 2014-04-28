#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=openssh
version=6.5p1
export MAKEFLAGS='-j 1'
download()
{
nwget http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.5p1.tar.gz
nwget ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-6.5p1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" openssh-6.5p1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
install -v -m700 -d /var/lib/sshd 
chown   -v root:sys /var/lib/sshd 

groupadd -g 50 sshd 
useradd -c 'sshd PrivSep' -d /var/lib/sshd -g sshd -s /bin/false -u 50 sshd

./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords --with-privsep-path=/var/lib/sshd 
make

make install                                  
install -v -m755 contrib/ssh-copy-id /usr/bin 
install -v -m644 contrib/ssh-copy-id.1 /usr/share/man/man1 
install -v -m755 -d /usr/share/doc/openssh-6.5p1           
install -v -m644 INSTALL LICENCE OVERVIEW README* /usr/share/doc/openssh-6.5p1

echo "PermitRootLogin no" >> /etc/ssh/sshd_config

ssh-keygen 
public_key="$(cat ~/.ssh/id_rsa.pub)" 
ssh REMOTE_HOSTNAME "echo ${public_key} >> ~/.ssh/authorized_keys" 
unset public_key

echo "PasswordAuthentication no" >> /etc/ssh/sshd_config 
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config

sed 's@d/login@d/sshd@g' /etc/pam.d/login > /etc/pam.d/sshd 
chmod 644 /etc/pam.d/sshd 
echo "UsePAM yes" >> /etc/ssh/sshd_config

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-sshd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
