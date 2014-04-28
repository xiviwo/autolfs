#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libreoffice
version=4.2.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.documentfoundation.org/libreoffice/src/4.2.0/libreoffice-translations-4.2.0.4.tar.xz
nwget http://download.documentfoundation.org/libreoffice/src/4.2.0/libreoffice-4.2.0.4.tar.xz
nwget http://download.documentfoundation.org/libreoffice/src/4.2.0/libreoffice-help-4.2.0.4.tar.xz
nwget http://download.documentfoundation.org/libreoffice/src/4.2.0/libreoffice-dictionaries-4.2.0.4.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libreoffice-4.2.0.4.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf libreoffice-4.2.0.4.tar.xz --no-overwrite-dir 
cd libreoffice-4.2.0.4

install -dm755 src 

tar -xf ../libreoffice-dictionaries-4.2.0.4.tar.xz --no-overwrite-dir --strip-components=1 

ln -svf ../../libreoffice-dictionaries-4.2.0.4.tar.xz src/ 
ln -svf ../../libreoffice-help-4.2.0.4.tar.xz src/

ln -svf ../../libreoffice-translations-4.2.0.4.tar.xz src/

export LO_PREFIX=<PREFIX>

sed -e "/gzip -f/d" -e "s|.1.gz|.1|g" -i bin/distro-install-desktop-integration        
sed -e "/distro-install-file-lists/d" -i Makefile.in 

chmod -v +x bin/unpack-sources                     
sed -e "s/target\.mk/langlist\.mk/" -e "s/tar -xf/tar -x --strip-components=1 -f/" -e "/tar -x/s/lo_src_dir/start_dir/" -i bin/unpack-sources                          

./autogen.sh --prefix=$LO_PREFIX --sysconfdir=/etc --with-vendor="BLFS" --with-lang="en-US pt-BR" --with-help --with-alloc=system --without-java --disable-gconf --disable-odk --disable-postgresql-sdbc --enable-release-build=yes --enable-python=system --with-system-boost --with-system-clucene --with-system-cairo --with-system-curl --with-system-expat --with-system-graphite --with-system-harfbuzz --with-system-icu --with-system-jpeg --with-system-lcms2 --with-system-libpng --with-system-libxml --with-system-mesa-headers --with-system-neon --with-system-npapi-headers --with-system-nss --with-system-odbc --with-system-openldap --with-system-openssl --with-system-poppler --with-system-redland --with-system-zlib --with-parallelism=$(getconf _NPROCESSORS_ONLN)

make build

make distro-pack-install                                    
install -v -m755 -d $LO_PREFIX/share/appdata                
install -v -m644    sysui/desktop/appstream-appdata/*.xml $LO_PREFIX/share/appdata

chown -cR 0:0 dictionaries/                                                        
mkdir -pv -pv $LO_PREFIX/lib/libreoffice/share/extensions/dict-en                      
cp -vR dictionaries/en/*    $LO_PREFIX/lib/libreoffice/share/extensions/dict-en    
mkdir -pv -pv $LO_PREFIX/lib/libreoffice/share/extensions/dict-pt-BR                   
cp -vR dictionaries/pt_BR/* $LO_PREFIX/lib/libreoffice/share/extensions/dict-pt-BR

mkdir -pv -pv /usr/share/pixmaps 
for i in writer base calc draw impress math startcenter writer
do
  ln -svf /opt/libreoffice-4.2.0.4/share/icons/hicolor/32x32/apps/libreoffice-$i.png /usr/share/pixmaps/
done
unset i


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
