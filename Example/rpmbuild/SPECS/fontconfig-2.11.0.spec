%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Fontconfig package contains a library and support programs used for configuring and customizing font access. 
Name:       fontconfig
Version:    2.11.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  freetype
Requires:  expat
Source0:    http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.11.0.tar.bz2
URL:        http://www.freedesktop.org/software/fontconfig/release
%description
 The Fontconfig package contains a library and support programs used for configuring and customizing font access. 
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --docdir=/usr/share/doc/fontconfig-2.11.0 --disable-docs --disable-static     &&
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