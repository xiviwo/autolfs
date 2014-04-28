%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Xfce4 Terminal is a GTK+ 2 terminal emulator. This is useful for running commands or programs in the comfort of an Xorg window; you can drag and drop files into the Xfce4 Terminal or copy and paste text with your mouse. 
Name:       xfce4-terminal
Version:    0.6.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libxfce4ui
Requires:  vte
Source0:    http://archive.xfce.org/src/apps/xfce4-terminal/0.6/xfce4-terminal-0.6.3.tar.bz2
URL:        http://archive.xfce.org/src/apps/xfce4-terminal/0.6
%description
 Xfce4 Terminal is a GTK+ 2 terminal emulator. This is useful for running commands or programs in the comfort of an Xorg window; you can drag and drop files into the Xfce4 Terminal or copy and paste text with your mouse. 
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