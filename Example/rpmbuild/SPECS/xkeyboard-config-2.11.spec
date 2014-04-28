%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The XKeyboardConfig package contains the keyboard configuration database for the X Window System. 
Name:       xkeyboard-config
Version:    2.11
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  intltool
Requires:  xorg-libraries
Source0:    http://xorg.freedesktop.org/archive/individual/data/xkeyboard-config/xkeyboard-config-2.11.tar.bz2
Source1:    ftp://ftp.x.org/pub/individual/data/xkeyboard-config/xkeyboard-config-2.11.tar.bz2
URL:        http://xorg.freedesktop.org/archive/individual/data/xkeyboard-config
%description
 The XKeyboardConfig package contains the keyboard configuration database for the X Window System. 
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
./configure $XORG_CONFIG --with-xkb-rules-symlink=xorg &&
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