%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Speex is an audio compression format designed especially for speech. It is well-adapted to internet applications and provides useful features that are not present in most other CODECs. 
Name:       speex
Version:    1.2rc1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libogg
Source0:    http://downloads.us.xiph.org/releases/speex/speex-1.2rc1.tar.gz
URL:        http://downloads.us.xiph.org/releases/speex
%description
 Speex is an audio compression format designed especially for speech. It is well-adapted to internet applications and provides useful features that are not present in most other CODECs. 
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
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/speex-1.2rc1 &&
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