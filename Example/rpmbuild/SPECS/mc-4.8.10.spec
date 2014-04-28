%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     MC (Midnight Commander) is a text-mode full-screen file manager and visual shell. It provides a clear, user-friendly, and somewhat protected interface to a Unix system while making many frequent file operations more efficient and preserving the full power of the command prompt. 
Name:       mc
Version:    4.8.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  pcre
Source0:    http://anduin.linuxfromscratch.org/sources/BLFS/svn/m/mc-4.8.10.tar.xz
Source1:    ftp://ftp.osuosl.org/pub/midnightcommander/mc-4.8.10.tar.xz
URL:        http://anduin.linuxfromscratch.org/sources/BLFS/svn/m
%description
 MC (Midnight Commander) is a text-mode full-screen file manager and visual shell. It provides a clear, user-friendly, and somewhat protected interface to a Unix system while making many frequent file operations more efficient and preserving the full power of the command prompt. 
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
./configure --prefix=/usr --enable-charset --disable-static --sysconfdir=/etc --with-screen=ncurses 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share
make install  DESTDIR=${RPM_BUILD_ROOT} 

cp -v doc/keybind-migration.txt ${RPM_BUILD_ROOT}/usr/share/mc


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