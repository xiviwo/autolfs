%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Postfix package contains a Mail Transport Agent (MTA). This is useful for sending email to other users of your host machine. It can also be configured to be a central mail server for your domain, a mail relay agent or simply a mail delivery agent to your local Internet Service Provider. 
Name:       postfix
Version:    2.10.2
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  berkeley-db
Requires:  cyrus-sasl
Requires:  openssl
Source0:    ftp://ftp.porcupine.org/mirrors/postfix-release/official/postfix-2.10.2.tar.gz
URL:        ftp://ftp.porcupine.org/mirrors/postfix-release/official
%description
 The Postfix package contains a Mail Transport Agent (MTA). This is useful for sending email to other users of your host machine. It can also be configured to be a central mail server for your domain, a mail relay agent or simply a mail delivery agent to your local Internet Service Provider. 
%pre
groupadd -g 32 postfix

groupadd -g 33 postdrop

useradd -c "Postfix Daemon User" -d /var/spool/postfix -g postfix -s /bin/false -u 32 postfix

chown -v postfix:postfix /var/mail
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
sed -i "s/DB_VERSION_MAJOR == 5/DB_VERSION_MAJOR >= 5/" src/util/dict_db.c
sed -i 's/.\x08//g' README_FILES/*
make CCARGS="-DNO_NIS -DUSE_TLS -I/usr/include/openssl/ -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl" AUXLIBS="-lssl -lcrypto -lsasl2" makefiles %{?_smp_mflags} 

make %{?_smp_mflags} 
sh postfix-install -non-interactive daemon_directory=/usr/lib/postfix manpage_directory=/usr/share/man html_directory=/usr/share/doc/postfix-2.10.2/html readme_directory=/usr/share/doc/postfix-2.10.2/readme
cat >> /etc/aliases << "EOF"
# Begin /etc/aliases
MAILER-DAEMON:    postmaster
postmaster:       root
root:             <LOGIN>
# End /etc/aliases
EOF
/usr/sbin/postfix upgrade-configuration
/usr/sbin/postfix check 
/usr/sbin/postfix start
mkdir -pv /etc
mkdir -pv blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20130908.tar.bz2 -C blfs-boot-scripts --strip-components 1
cd blfs-boot-scripts

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd blfs-boot-scripts


make install-postfix DESTDIR=${RPM_BUILD_ROOT} 


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