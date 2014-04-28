%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Links is a text and graphics mode WWW browser. It includes support for rendering tables and frames, features background downloads, can display colors and has many other features. 
Name:       links
Version:    2.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gpm
Requires:  openssl
Source0:    http://links.twibright.com/download/links-2.8.tar.bz2
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/links-2.8.tar.bz2
URL:        http://links.twibright.com/download
%description
 Links is a text and graphics mode WWW browser. It includes support for rendering tables and frames, features background downloads, can display colors and has many other features. 
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
./configure --prefix=/usr --mandir=/usr/share/man &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -d -m755 ${RPM_BUILD_ROOT}/usr/share/doc/links-2.8 &&

install -v -m644 doc/links_cal/* KEYS BRAILLE_HOWTO ${RPM_BUILD_ROOT}/usr/share/doc/links-2.8


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