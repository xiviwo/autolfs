#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=wireshark
version=1.10.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.wireshark.org/download/src/all-versions/wireshark-1.10.5.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" wireshark-1.10.5.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cat > svnversion.h << "EOF"
#define SVNVERSION "BLFS"
#define SVNPATH "source"
EOF

cat > make-version.pl << "EOF"
#!/usr/bin/perl
EOF

groupadd -g 62 wireshark

./configure --prefix=/usr --sysconfdir=/etc 
make

make install 

install -v -m755 -d /usr/share/doc/wireshark-1.10.5 
install -v -m755 -d /usr/share/pixmaps/wireshark 

install -v -m644    README{,.linux} doc/README.* doc/*.{pod,txt} /usr/share/doc/wireshark-1.10.5 

pushd /usr/share/doc/wireshark-1.10.5 
   for FILENAME in ../../wireshark/*.html; do
      ln -svf -v -f $FILENAME .
   done 
popd 

install -v -m644 -D wireshark.desktop /usr/share/applications/wireshark.desktop 

install -v -m644 -D image/wsicon48.png /usr/share/pixmaps/wireshark.png 

install -v -m644    image/*.{png,ico,xpm,bmp} /usr/share/pixmaps/wireshark

install -v -m644 <Downloaded_Files> /usr/share/doc/wireshark-1.10.5

chown -v root:wireshark /usr/bin/{tshark,dumpcap} 
chmod -v 6550 /usr/bin/{tshark,dumpcap}


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
