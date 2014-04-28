#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sane
version=1.0.24
export MAKEFLAGS='-j 4'
download()
{
nwget http://alioth.debian.org/frs/download.php/file/1140/sane-frontends-1.0.14.tar.gz
nwget http://fossies.org/linux/misc//sane-backends-1.0.24.tar.gz
nwget ftp://ftp2.sane-project.org/pub/sane/sane-frontends-1.0.14.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" sane-backends-1.0.24.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 70 scanner

su $(whoami)

./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-docdir=/usr/share/doc/sane-backend-1.0.24 --with-group=scanner                             
make                                                         

sed -i -e 's/Jul 31 07:52:48/Oct  7 08:58:33/' -e 's/1.0.24git/1.0.24/' testsuite/tools/data/db.ref testsuite/tools/data/html-mfgs.ref testsuite/tools/data/usermap.ref testsuite/tools/data/html-backends-split.ref testsuite/tools/data/udev+acl.ref testsuite/tools/data/udev.ref

make install                                         
install -m 644 -v tools/udev/libsane.rules /etc/udev/rules.d/65-scanner.rules 
chgrp -v scanner  /var/lock/sane

sed -i -e "/SANE_CAP_ALWAYS_SETTABLE/d" src/gtkglue.c 
./configure --prefix=/usr 
make

make install 
install -v -m644 doc/sane.png xscanimage-icon-48x48-2.png /usr/share/sane

ln -v -s ../../../../bin/xscanimage /usr/lib/gimp/2.0/plug-ins

cat >> /etc/sane.d/net.conf << "EOF"
connect_timeout = 60
<server_ip>
EOF

mkdir -pv -pv /usr/share/{applications,pixmaps}               

cat > /usr/share/applications/xscanimage.desktop << "EOF" 
[Desktop Entry]
Encoding=UTF-8
Name=XScanImage - Scanning
Comment=Acquire images from a scanner
Exec=xscanimage
Icon=xscanimage
Terminal=false
Type=Application
Categories=Application;Graphics
EOF

ln -svf ../sane/xscanimage-icon-48x48-2.png /usr/share/pixmaps/xscanimage.png


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
