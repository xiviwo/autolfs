#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=other-programming-tools
version=
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/cachecc1
nwget http://wiki.clean.cs.ru.nl/Clean
nwget http://pike.ida.liu.se/download/pub/pike
nwget https://gforge.inria.fr/frs/?group_id=184
nwget https://github.com/mozart/mozart2#downloads
nwget http://www.mono-project.com/Main_Page
nwget http://downloads.sourceforge.net/gtk2-perl
nwget http://www.cs.uu.nl/wiki/bin/view/Helium/WebHome
nwget http://techbase.kde.org/Development/Languages
nwget http://sdcc.sourceforge.net/snap.php#Source
nwget http://downloads.sourceforge.net/regina-rexx
nwget http://lavape.sourceforge.net/index.htm
nwget http://www.gtk.org/language-bindings.php
nwget http://projects.gnome.org/anjuta/index.shtml
nwget http://felix-lang.org/$/usr/local/lib/felix/tarballs
nwget http://nemerle.org/Downloads
nwget http://nemerle.org/About
nwget http://yorick.sourceforge.net/index.php
nwget http://www.rapideuphoria.com/v20.htm
nwget http://www.jsoftware.com/stable.htm
nwget http://www.latrobe.edu.au/humanities/research/research-projects/past-projects/joy-programming-language
nwget http://iolanguage.org
nwget http://wiki.clean.cs.ru.nl/Download_Clean

}
unpack()
{
preparepack "$pkgname" "$version" 
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
:
}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
