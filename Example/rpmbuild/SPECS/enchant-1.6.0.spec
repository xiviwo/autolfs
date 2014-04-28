%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The enchant package provide a generic interface into various existing spell checking libraries. 
Name:       enchant
Version:    1.6.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  aspell
Source0:    http://www.abisource.com/downloads/enchant/1.6.0/enchant-1.6.0.tar.gz
Source1:    ftp://ftp.netbsd.org/pub/pkgsrc/distfiles/enchant-1.6.0.tar.gz
URL:        http://www.abisource.com/downloads/enchant/1.6.0
%description
 The enchant package provide a generic interface into various existing spell checking libraries. 
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