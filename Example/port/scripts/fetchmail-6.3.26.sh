#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=fetchmail
version=6.3.26
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.at.gnucash.org/pub/infosys/mail/fetchmail/fetchmail-6.3.26.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" fetchmail-6.3.26.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-ssl --enable-fallback=procmail 
make

make install

cat > ~/.fetchmailrc << "EOF"
set logfile /var/log/fetchmail.log
set no bouncemail
set postmaster root

poll SERVERNAME :
    user mao pass ping;
    mda "/usr/bin/procmail -f %F -d %T";
EOF

chmod -v 0600 ~/.fetchmailrc


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
