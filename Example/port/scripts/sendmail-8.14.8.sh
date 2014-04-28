#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sendmail
version=8.14.8
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.sendmail.org/pub/sendmail/sendmail.8.14.8.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" sendmail.8.14.8.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 26 smmsp                               
useradd -c "Sendmail Daemon" -g smmsp -d /dev/null -s /bin/false -u 26 smmsp                  
chmod -v 1777 /var/mail                            
install -v -m700 -d /var/spool/mqueue

cat >> devtools/Site/site.config.m4 << "EOF"
APPENDDEF(`confENVDEF',`-DSTARTTLS -DSASL -DLDAPMAP')
APPENDDEF(`confLIBS', `-lssl -lcrypto -lsasl2 -lldap -llberi -ldb')
APPENDDEF(`confINCDIRS', `-I/usr/include/sasl')
EOF

cat >> devtools/Site/site.config.m4 << "EOF"
define(`confMANGRP',`root')
define(`confMANOWN',`root')
define(`confSBINGRP',`root')
define(`confUBINGRP',`root')
define(`confUBINOWN',`root')

EOF

sed -i 's|/usr/man/man|/usr/share/man/man|' devtools/OS/Linux           

sed -i -r "s/^# if (DB.*)$/# if (\1) || DB_VERSION_MAJOR >= 5/" include/sm/bdb.h            

cd sendmail                     
sh Build                        
cd ../cf/cf                     
cp generic-linux.mc sendmail.mc 
sh Build sendmail.cf

install -v -d -m755 /etc/mail 
sh Build install-cf 

cd ../..            
sh Build install    

install -v -m644 cf/cf/{submit,sendmail}.mc /etc/mail 
cp -v -R cf/* /etc/mail                               

install -v -m755 -d /usr/share/doc/sendmail-8.14.8/{cf,sendmail} 

install -v -m644 CACerts FAQ KNOWNBUGS LICENSE PGPKEYS README RELEASE_NOTES /usr/share/doc/sendmail-8.14.8 

install -v -m644 sendmail/{README,SECURITY,TRACEFLAGS,TUNING} /usr/share/doc/sendmail-8.14.8/sendmail 

install -v -m644 cf/README /usr/share/doc/sendmail-8.14.8/cf 

for manpage in sendmail editmap mailstats makemap praliases smrsh
do
    install -v -m644 $manpage/$manpage.8 /usr/share/man/man8
done 

install -v -m644 sendmail/aliases.5    /usr/share/man/man5 
install -v -m644 sendmail/mailq.1      /usr/share/man/man1 
install -v -m644 sendmail/newaliases.1 /usr/share/man/man1 
install -v -m644 vacation/vacation.1   /usr/share/man/man1

cd doc/op                                       
sed -i 's/groff/GROFF_NO_SGR=1 groff/' Makefile 
make op.txt op.pdf

install -v -d -m755 /usr/share/doc/sendmail-8.14.8 
install -v -m644 op.ps op.txt op.pdf /usr/share/doc/sendmail-8.14.8 
cd ../..

echo $(hostname) > /etc/mail/local-host-names
cat > /etc/mail/aliases << "EOF"
postmaster: root
MAILER-DAEMON: root

EOF
newaliases -v

cd /etc/mail 
m4 m4/cf.m4 sendmail.mc > sendmail.cf

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-sendmail


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
