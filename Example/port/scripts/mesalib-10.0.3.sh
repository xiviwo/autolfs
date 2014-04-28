#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mesalib
version=10.0.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/MesaLib-10.0.3-add_xdemos-1.patch
nwget ftp://ftp.freedesktop.org/pub/mesa/10.0.3/MesaLib-10.0.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" MesaLib-10.0.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../MesaLib-10.0.3-add_xdemos-1.patch

./autogen.sh CFLAGS="-O2" CXXFLAGS="-O2" --prefix=$XORG_PREFIX --sysconfdir=/etc --enable-texture-float --enable-gles1 --enable-gles2 --enable-openvg --enable-osmesa --enable-xa --enable-gbm --enable-gallium-egl --enable-gallium-gbm --enable-glx-tls --with-llvm-shared-libs --with-egl-platforms="drm,x11" --with-gallium-drivers="nouveau,r300,r600,radeonsi,svga,swrast" 
make

make -C xdemos DEMOS_PREFIX=$XORG_PREFIX

make install

make -C xdemos DEMOS_PREFIX=$XORG_PREFIX install

install -v -dm755 /usr/share/doc/MesaLib-10.0.3 
cp -rfv docs/* /usr/share/doc/MesaLib-10.0.3


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
