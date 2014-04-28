#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=running-a-subversion-server
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{

cd ${SOURCES} 

}
build()
{
groupadd -g 56 svn 
useradd -c "SVN Owner" -d /home/svn -m -g svn -s /bin/false -u 56 svn

groupadd -g 57 svntest 
usermod -G svntest -a svn

mv /usr/bin/svn /usr/bin/svn.orig 
mv /usr/bin/svnserve /usr/bin/svnserve.orig 
cat >> /usr/bin/svn << "EOF"
#!/bin/sh
umask 002
/usr/bin/svn.orig "$@"
EOF
cat >> /usr/bin/svnserve << "EOF"
#!/bin/sh
umask 002
/usr/bin/svnserve.orig "$@"
EOF
chmod 0755 /usr/bin/svn{,serve}

install -v -m 0755 -d /srv/svn 
install -v -m 0755 -o svn -g svn -d /srv/svn/repositories 
svnadmin create --fs-type fsfs /srv/svn/repositories/svntest

svn import -m "Initial import." </path/to/source/tree> file:///srv/svn/repositories/svntest

chown -R svn:svntest /srv/svn/repositories/svntest    
chmod -R g+w         /srv/svn/repositories/svntest    
chmod g+s            /srv/svn/repositories/svntest/db 
usermod -G svn,svntest -a mao

svnlook tree /srv/svn/repositories/svntest/

cp /srv/svn/repositories/svntest/conf/svnserve.conf /srv/svn/repositories/svntest/conf/svnserve.conf.default 

cat > /srv/svn/repositories/svntest/conf/svnserve.conf << "EOF"
[general]
anon-access = read
auth-access = write
EOF

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-svn


}
download;unpack;build
