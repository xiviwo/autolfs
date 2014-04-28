%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Fetchmail package contains a mail retrieval program. It retrieves mail from remote mail servers and forwards it to the local (client) machine's delivery system, so it can then be read by normal mail user agents. 
Name:       fetchmail
Version:    6.3.26
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  openssl
Requires:  procmail
Source0:    ftp://ftp.at.gnucash.org/pub/infosys/mail/fetchmail/fetchmail-6.3.26.tar.xz
URL:        ftp://ftp.at.gnucash.org/pub/infosys/mail/fetchmail
%description
 The Fetchmail package contains a mail retrieval program. It retrieves mail from remote mail servers and forwards it to the local (client) machine's delivery system, so it can then be read by normal mail user agents. 
%pre
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
./configure --prefix=/usr --with-ssl --enable-fallback=procmail &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat > ~/.fetchmailrc << "EOF"

set logfile /var/log/fetchmail.log

set no bouncemail

set postmaster root

poll SERVERNAME :

    user mao pass ping;

    mda "/usr/bin/procmail -f %F -d %T";

EOF

chmod -v 0600 ~/.fetchmailrc
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog