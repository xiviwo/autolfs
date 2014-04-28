#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gstreamer
version=0.10.36
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/gstreamer/0.10/gstreamer-0.10.36.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/gstreamer/0.10/gstreamer-0.10.36.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gstreamer-0.10.36.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i  -e '/YYLEX_PARAM/d' -e '/parse-param.*scanner/i %lex-param { void *scanner }' gst/parse/grammar.y 

./configure --prefix=/usr --disable-static 
make

make install 
install -v -m755 -d /usr/share/doc/gstreamer-0.10/design 
install -v -m644 docs/design/*.txt /usr/share/doc/gstreamer-0.10/design 

if [ -d /usr/share/doc/gstreamer-0.10/faq/html ]; then
    chown -v -R root:root /usr/share/doc/gstreamer-0.10/*/html
fi

gst-launch -v fakesrc num_buffers=5 ! fakesink


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
