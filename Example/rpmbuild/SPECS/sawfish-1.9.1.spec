%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The sawfish package contains a window manager. This is useful for organizing and displaying windows where all window decorations are configurable and all user-interface policy is controlled through the extension language. 
Name:       sawfish
Version:    1.9.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  rep-gtk
Requires:  which
Requires:  gtk
Requires:  pango
Source0:    http://download.tuxfamily.org/sawfish/sawfish-1.9.1.tar.xz
URL:        http://download.tuxfamily.org/sawfish
%description
 The sawfish package contains a window manager. This is useful for organizing and displaying windows where all window decorations are configurable and all user-interface policy is controlled through the extension language. 
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
./configure --prefix=/usr --with-pango  
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
cat >> ~/.xinitrc << "EOF"

exec sawfish

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog