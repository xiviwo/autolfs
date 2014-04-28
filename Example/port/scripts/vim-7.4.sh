#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=vim
version=7.4
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2


}
unpack()
{
preparepack "$pkgname" "$version" vim-7.4.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf ../vim-7.2-lang.tar.gz --strip-components=1

echo '#define SYS_VIMRC_FILE  "/etc/vimrc"' >>  src/feature.h 
echo '#define SYS_GVIMRC_FILE "/etc/gvimrc"' >> src/feature.h 
./configure --prefix=/usr --with-features=huge 
make

make install

ln -snfv ../vim/vim74/doc /usr/share/doc/vim-7.4

rsync -avzcP --delete --exclude="/dos/" --exclude="/spell/" ftp.nluug.nl::Vim/runtime/ ./runtime/

make -C src installruntime 
vim -c ":helptags /usr/share/doc/vim-7.4" -c ":q"


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
