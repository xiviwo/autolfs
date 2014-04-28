%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Psmisc package contains programs for displaying information about running processes. 
Name:       psmisc
Version:    22.20
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://prdownloads.sourceforge.net/psmisc/psmisc-22.20.tar.gz

URL:        http://prdownloads.sourceforge.net/psmisc
%description
 The Psmisc package contains programs for displaying information about running processes. 
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
./configure --prefix=/usr
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/bin
make install DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/bin/fuser   ${RPM_BUILD_ROOT}/bin

mv -v ${RPM_BUILD_ROOT}/usr/bin/killall ${RPM_BUILD_ROOT}/bin


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