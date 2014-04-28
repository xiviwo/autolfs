#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=fuse
version=2.9.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/fuse/fuse-2.9.3.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" fuse-2.9.3.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static INIT_D_PATH=/tmp/init.d 
make

make install 

mv -v   /usr/lib/libfuse.so.* /lib 
ln -sfv ../../lib/libfuse.so.2.9.3 /usr/lib/libfuse.so 
rm -rf  /tmp/init.d 

install -v -m755 -d /usr/share/doc/fuse-2.9.3 
install -v -m644    doc/{how-fuse-works,kernel.txt} /usr/share/doc/fuse-2.9.3

cat > /etc/fuse.conf << "EOF"
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#
#mount_max = 1000

# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
#
#user_allow_other
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
