%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Procps-ng package contains programs for monitoring processes. 
Name:       procps-ng
Version:    3.3.9
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://sourceforge.net/projects/procps-ng/files/Production/procps-ng-3.3.9.tar.xz

URL:        http://sourceforge.net/projects/procps-ng/files/Production
%description
 The Procps-ng package contains programs for monitoring processes. 
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
./configure --prefix=/usr --exec-prefix= --libdir=/usr/lib --docdir=/usr/share/doc/procps-ng-3.3.9 --disable-static --disable-kill
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/bin
make install DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/bin/pidof ${RPM_BUILD_ROOT}/bin

mv -v ${RPM_BUILD_ROOT}/usr/lib/libprocps.so.* ${RPM_BUILD_ROOT}/lib

ln -sfv ../../lib/$(readlink ${RPM_BUILD_ROOT}/usr/lib/libprocps.so) ${RPM_BUILD_ROOT}/usr/lib/libprocps.so


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