%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The sendmail package contains a Mail Transport Agent (MTA). 
Name:       sendmail
Version:    8.14.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  openldap
Source0:    ftp://ftp.sendmail.org/pub/sendmail/sendmail.8.14.8.tar.gz
URL:        ftp://ftp.sendmail.org/pub/sendmail
%description
 The sendmail package contains a Mail Transport Agent (MTA). 
%pre
groupadd -g 26 smmsp                                || :

useradd -c "Sendmail Daemon" -g smmsp -d /dev/null -s /bin/false -u 26 smmsp                   || :

install -v -m700 -d /var/spool/mqueue
%prep
export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
rm -rf %{srcdir}
mkdir -pv %{srcdir} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{srcdir}
	;;
	*tar)
	tar xf %SOURCE0 -C %{srcdir} 
	;;
	*)
	tar xf %SOURCE0 -C %{srcdir} --strip-components 1
	;;
esac

%build
cd %{srcdir}
chmod -v 1777 /var/mail                            &&
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
sed -i 's|/usr/man/man|/usr/share/man/man|' devtools/OS/Linux           &&
sed -i -r "s/^# if (DB.*)$/# if (\1) || DB_VERSION_MAJOR >= 5/" include/sm/bdb.h            &&
cd sendmail                     &&
sh Build                        &&
cd  %_sourcedir/cf/cf                     &&
cp generic-linux.mc sendmail.mc &&
sh Build sendmail.cf

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd sendmail                     &&

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/sendmail-8.14.8
mkdir -pv ${RPM_BUILD_ROOT}/etc/mail
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man8
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man5
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man1
install -v -d -m755 ${RPM_BUILD_ROOT}/etc/mail &&

sh Build install-cf &&
cd  %_sourcedir/..            &&
sh Build install    &&
install -v -m644 cf/cf/{submit,sendmail}.mc ${RPM_BUILD_ROOT}/etc/mail &&

cp -v -R cf/* ${RPM_BUILD_ROOT}/etc/mail                               &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/sendmail-8.14.8/{cf,sendmail} &&

install -v -m644 CACerts FAQ KNOWNBUGS LICENSE PGPKEYS README RELEASE_NOTES ${RPM_BUILD_ROOT}/usr/share/doc/sendmail-8.14.8 &&

install -v -m644 sendmail/{README,SECURITY,TRACEFLAGS,TUNING} ${RPM_BUILD_ROOT}/usr/share/doc/sendmail-8.14.8/sendmail &&

install -v -m644 cf/README ${RPM_BUILD_ROOT}/usr/share/doc/sendmail-8.14.8/cf &&

for manpage in sendmail editmap mailstats makemap praliases smrsh
do
    install -v -m644 $manpage/$manpage.8 ${RPM_BUILD_ROOT}/usr/share/man/man8

done &&
install -v -m644 sendmail/aliases.5    ${RPM_BUILD_ROOT}/usr/share/man/man5 &&

install -v -m644 sendmail/mailq.1      ${RPM_BUILD_ROOT}/usr/share/man/man1 &&

install -v -m644 sendmail/newaliases.1 ${RPM_BUILD_ROOT}/usr/share/man/man1 &&

install -v -m644 vacation/vacation.1   ${RPM_BUILD_ROOT}/usr/share/man/man1

cd doc/op                                       &&
sed -i 's/groff/GROFF_NO_SGR=1 groff/' Makefile &&
make op.txt op.pdf
install -v -d -m755 ${RPM_BUILD_ROOT}/usr/share/doc/sendmail-8.14.8 &&

install -v -m644 op.ps op.txt op.pdf ${RPM_BUILD_ROOT}/usr/share/doc/sendmail-8.14.8 &&

cd  %_sourcedir/..
echo $(hostname) > ${RPM_BUILD_ROOT}/etc/mail/local-host-names

cat > /etc/mail/aliases << "EOF"
postmaster: root
MAILER-DAEMON: root
EOF
newaliases -v
cd ${RPM_BUILD_ROOT}/etc/mail &&

m4 m4/cf.m4 sendmail.mc > sendmail.cf
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-sendmail DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog