%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Inetutils package contains programs for basic networking. 
Name:       inetutils
Version:    1.9.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/inetutils/inetutils-1.9.2.tar.gz

URL:        http://ftp.gnu.org/gnu/inetutils
%description
 The Inetutils package contains programs for basic networking. 
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
echo '#define PATH_PROCNET_DEV "/proc/net/dev"' >> ifconfig/system/linux.h
./configure --prefix=/usr --localstatedir=/var --disable-logger --disable-syslogd --disable-whois --disable-servers
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/sbin
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin/
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/bin
make install DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/bin/{hostname,ping,ping6,traceroute} ${RPM_BUILD_ROOT}/bin

mv -v ${RPM_BUILD_ROOT}/usr/bin/ifconfig ${RPM_BUILD_ROOT}/sbin


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