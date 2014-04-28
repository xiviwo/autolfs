#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=texlive
version=20130530
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://tug.org/texlive/historic/2013/texlive-20130530-source.tar.xz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/texlive-20130530-source-fix_asymptote-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" texlive-20130530-source.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../texlive-20130530-source-fix_asymptote-1.patch 

mkdir -pv texlive-build 
cd texlive-build    

../configure --prefix=/opt/texlive/2013 --bindir=/opt/texlive/2013/bin/x86_64-linux --datarootdir=/opt/texlive/2013 --includedir=/usr/include --infodir=/opt/texlive/2013/texmf-dist/doc/info --libdir=/usr/lib --mandir=/opt/texlive/2013/texmf-dist/doc/man --disable-native-texlive-build --disable-static --enable-shared --with-system-libgs --with-system-poppler --with-system-freetype2 --with-system-fontconfig --with-system-libpng --with-system-icu --with-system-graphite2 --with-system-harfbuzz --with-system-xpdf --with-system-poppler --with-system-cairo --with-system-pixman --with-system-zlib --with-banner-add=" - BLFS" 

pushd ../utils/asymptote 
    echo "ac_cv_lib_m_sqrt=yes"     >config.cache 
    echo "ac_cv_lib_z_deflate=yes" >>config.cache 

./configure LIBS="-ltirpc " --prefix=/opt/texlive/2013/ --bindir=/opt/texlive/2013/bin/x86_64-linux --enable-texlive-build --datarootdir=/opt/texlive/2013/texmf-dist --infodir=/opt/texlive/2013/texmf-dist/doc/info --mandir=/opt/texlive/2013/texmf-dist/doc/man --cache-file=config.cache 
popd 

make 
make -C ../utils/asymptote

make install 
make -C ../utils/asymptote install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
