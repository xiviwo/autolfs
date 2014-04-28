%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libxcb package provides an interface to the X Window System protocol, which replaces the current Xlib interface. Xlib can also use XCB as a transport layer, allowing software to make requests and receive responses with both. 
Name:       libxcb
Version:    1.9.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  libxau
Requires:  libxdmcp
Requires:  libxslt
Requires:  xcb-proto
Source0:    http://xcb.freedesktop.org/dist/libxcb-1.9.1.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/svn/libxcb-1.9.1-automake_bug-1.patch
URL:        http://xcb.freedesktop.org/dist
%description
 The libxcb package provides an interface to the X Window System protocol, which replaces the current Xlib interface. Xlib can also use XCB as a transport layer, allowing software to make requests and receive responses with both. 
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
patch -Np1 -i %_sourcedir/libxcb-1.9.1-automake_bug-1.patch 
sed -e "s/pthread-stubs//" -i configure.ac 
autoreconf -fi 
./configure $XORG_CONFIG --docdir='${datadir}'/doc/libxcb-1.9.1 --enable-xinput --enable-xkb 
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