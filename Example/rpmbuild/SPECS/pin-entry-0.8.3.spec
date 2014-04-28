%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The PIN-Entry package contains a collection of simple PIN or pass-phrase entry dialogs which utilize the Assuan protocol as described by the Ägypten project. PIN-Entry programs are usually invoked by the gpg-agent daemon, but can be run from the command line as well. There are programs for various text-based and GUI environments, including interfaces designed for Ncurses (text-based), GTK+, GTK+2, Qt3, and Qt4. 
Name:       pin-entry
Version:    0.8.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.gnupg.org/gcrypt/pinentry/pinentry-0.8.3.tar.bz2
URL:        ftp://ftp.gnupg.org/gcrypt/pinentry
%description
 The PIN-Entry package contains a collection of simple PIN or pass-phrase entry dialogs which utilize the Assuan protocol as described by the Ägypten project. PIN-Entry programs are usually invoked by the gpg-agent daemon, but can be run from the command line as well. There are programs for various text-based and GUI environments, including interfaces designed for Ncurses (text-based), GTK+, GTK+2, Qt3, and Qt4. 
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
./configure --prefix=/usr &&
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
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog