#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=wicd
version=1.7.2.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://launchpad.net/wicd/1.7/1.7.2.4/+download/wicd-1.7.2.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" wicd-1.7.2.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/wpath.logrotate\|wpath.systemd/d' setup.py 
rm po/*.po                                          
python setup.py configure --no-install-kde --no-install-acpi --no-install-pmutils --no-install-init

python setup.py install

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-wicd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
