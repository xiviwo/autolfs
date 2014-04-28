#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gst-plugins-good
version=0.10.31
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/gst-plugins-good/0.10/gst-plugins-good-0.10.31.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/gst-plugins-good/0.10/gst-plugins-good-0.10.31.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gst-plugins-good-0.10.31.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e "/input:/d" sys/v4l2/gstv4l2bufferpool.c 
sed -i -e "/case V4L2_CID_HCENTER/d" -e "/case V4L2_CID_VCENTER/d" sys/v4l2/v4l2_calls.c 
./configure --prefix=/usr --sysconfdir=/etc --with-gtk=3.0 
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
