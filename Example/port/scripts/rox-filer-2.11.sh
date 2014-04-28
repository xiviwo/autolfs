#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=rox-filer
version=2.11
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/rox/rox-filer-2.11.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" rox-filer-2.11.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cd ROX-Filer                                                        
sed -i 's:g_strdup(getenv("APP_DIR")):"/usr/share/rox":' src/main.c 

mkdir -pv build                        
pushd build                        
  ../src/configure LIBS="-lm -ldl" 
  make                             
popd

mkdir -pv -p /usr/share/rox                              
cp -av Help Messages Options.xml ROX images style.css .DirIcon /usr/share/rox 

cp -av ../rox.1 /usr/share/man/man1                  
cp -v  ROX-Filer /usr/bin/rox                        
chown -Rv root:root /usr/bin/rox /usr/share/rox      

cd /usr/share/rox/ROX/MIME                           
ln -svf text-x-{diff,patch}.png                       
ln -svf application-x-font-{afm,type1}.png            
ln -svf application-xml{,-dtd}.png                    
ln -svf application-xml{,-external-parsed-entity}.png 
ln -svf application-{,rdf+}xml.png                    
ln -svf application-x{ml,-xbel}.png                   
ln -svf application-{x-shell,java}script.png          
ln -svf application-x-{bzip,xz}-compressed-tar.png    
ln -svf application-x-{bzip,lzma}-compressed-tar.png  
ln -svf application-x-{bzip-compressed-tar,lzo}.png   
ln -svf application-x-{bzip,xz}.png                   
ln -svf application-x-{gzip,lzma}.png                 
ln -svf application-{msword,rtf}.png

cat > /path/to/hostname/AppRun << "HERE_DOC"
#!/bin/bash

MOUNT_PATH="${0%/*}"
HOST=${MOUNT_PATH##*/}
export MOUNT_PATH HOST
sshfs -o nonempty ${HOST}:/ ${MOUNT_PATH}
rox -x ${MOUNT_PATH}
HERE_DOC

chmod 755 /path/to/hostname/AppRun

cat > /usr/bin/myumount << "HERE_DOC" 
#!/bin/bash
sync
if mount | grep "${@}" | grep -q fuse
then fusermount -u "${@}"
else umount "${@}"
fi
HERE_DOC

chmod 755 /usr/bin/myumount

ln -svf ../rox/.DirIcon /usr/share/pixmaps/rox.png 
mkdir -pv -p /usr/share/applications 

cat > /usr/share/applications/rox.desktop << "HERE_DOC"
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Rox
Comment=The Rox File Manager
Icon=rox
Exec=rox
Categories=GTK;Utility;Application;System;Core;
StartupNotify=true
Terminal=false
HERE_DOC


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
