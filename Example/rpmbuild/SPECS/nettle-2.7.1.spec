%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Nettle package contains the low-level cryptographic library that is designed to fit easily in many contexts. 
Name:       nettle
Version:    2.7.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/nettle/nettle-2.7.1.tar.gz
Source1:    ftp://ftp.gnu.org/gnu/nettle/nettle-2.7.1.tar.gz
URL:        http://ftp.gnu.org/gnu/nettle
%description
 The Nettle package contains the low-level cryptographic library that is designed to fit easily in many contexts. 
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
sed -i '/^install-here/ s/install-static//' Makefile

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/nettle-2.7.1
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/nettle-2.7.1 &&

install -v -m644 nettle.html ${RPM_BUILD_ROOT}/usr/share/doc/nettle-2.7.1


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libhogweed.so.2.5 /usr/lib/libnettle.so.4.7 &&
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog