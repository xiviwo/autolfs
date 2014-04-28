%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Heirloom mailx package (formerly known as the Nail package) contains mailx, a command-line Mail User Agent derived from Berkeley Mail. It is intended to provide the functionality of the POSIX mailx command with additional support for MIME messages, IMAP (including caching), POP3, SMTP, S/MIME, message threading/sorting, scoring, and filtering. Heirloom mailx is especially useful for writing scripts and batch processing. 
Name:       mailx
Version:    12.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/heirloom/mailx-12.4.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/mailx-12.4-openssl_1.0.0_build_fix-1.patch
URL:        http://downloads.sourceforge.net/heirloom
%description
 The Heirloom mailx package (formerly known as the Nail package) contains mailx, a command-line Mail User Agent derived from Berkeley Mail. It is intended to provide the functionality of the POSIX mailx command with additional support for MIME messages, IMAP (including caching), POP3, SMTP, S/MIME, message threading/sorting, scoring, and filtering. Heirloom mailx is especially useful for writing scripts and batch processing. 
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
patch -Np1 -i %_sourcedir/mailx-12.4-openssl_1.0.0_build_fix-1.patch &&
make SENDMAIL=/usr/sbin/sendmail -j1 %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/mailx-12.4
make PREFIX=${RPM_BUILD_ROOT}/usr UCBINSTALL=${RPM_BUILD_ROOT}/usr/bin/install install && DESTDIR=${RPM_BUILD_ROOT} 

ln -v -sf mailx ${RPM_BUILD_ROOT}/usr/bin/mail &&

ln -v -sf mailx ${RPM_BUILD_ROOT}/usr/bin/nail &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/mailx-12.4 &&

install -v -m644 README mailx.1.html ${RPM_BUILD_ROOT}/usr/share/doc/mailx-12.4


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