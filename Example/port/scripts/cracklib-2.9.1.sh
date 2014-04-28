#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cracklib
version=2.9.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/cracklib/cracklib-words-20080507.gz
nwget http://downloads.sourceforge.net/cracklib/cracklib-2.9.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" cracklib-2.9.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-default-dict=/lib/cracklib/pw_dict --disable-static 
make

make install 
mv -v /usr/lib/libcrack.so.* /lib 
ln -sfv ../../lib/$(readlink /usr/lib/libcrack.so) /usr/lib/libcrack.so

install -v -m644 -D    ../cracklib-words-20080507.gz /usr/share/dict/cracklib-words.gz     
gunzip -v                /usr/share/dict/cracklib-words.gz     
ln -v -sf cracklib-words /usr/share/dict/words                 
echo $(hostname) >>      /usr/share/dict/cracklib-extra-words  
install -v -m755 -d      /lib/cracklib                         
create-cracklib-dict     /usr/share/dict/cracklib-words /usr/share/dict/cracklib-extra-words

make test


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
