%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The EsounD package contains the Enlightened Sound Daemon. This is useful for mixing together several digitized audio streams for playback by a single device. 
Name:       esound
Version:    0.2.41
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  audiofile
Source0:    http://ftp.gnome.org/pub/gnome/sources/esound/0.2/esound-0.2.41.tar.bz2
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/esound/0.2/esound-0.2.41.tar.bz2
URL:        http://ftp.gnome.org/pub/gnome/sources/esound/0.2
%description
 The EsounD package contains the Enlightened Sound Daemon. This is useful for mixing together several digitized audio streams for playback by a single device. 
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
LIBS=-lm ./configure --prefix=/usr --sysconfdir=/etc 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/esound-0.2.41
make install docdir=${RPM_BUILD_ROOT}/usr/share/doc/esound-0.2.41 DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -v root:root /usr/share/doc/esound-0.2.41/*
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog