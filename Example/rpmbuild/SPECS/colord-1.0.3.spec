%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Colord is a system activated daemon that maps devices to color profiles. It is used by GNOME Color Manager for system integration and use when there are no users logged in. 
Name:       colord
Version:    1.0.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  d-bus
Requires:  libgusb
Requires:  little-cms
Requires:  sqlite
Requires:  gobject-introspection
Requires:  polkit
Requires:  vala
Source0:    http://www.freedesktop.org/software/colord/releases/colord-1.0.3.tar.xz
URL:        http://www.freedesktop.org/software/colord/releases
%description
 Colord is a system activated daemon that maps devices to color profiles. It is used by GNOME Color Manager for system integration and use when there are no users logged in. 
%pre
groupadd -g 71 colord

useradd -c "Color Daemon Owner" -d /var/lib/colord -u 71 -g colord -s /bin/false colord
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
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --libexecdir=/usr/lib/colord --with-daemon-user=colord --enable-vala --disable-bash-completion --disable-systemd-login --disable-static 
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