%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The ALSA Utilities package contains various utilities which are useful for controlling your sound card. 
Name:       alsa-utils
Version:    1.0.27.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  alsa-lib
Source0:    http://alsa.cybermirror.org/utils/alsa-utils-1.0.27.2.tar.bz2
Source1:    ftp://ftp.alsa-project.org/pub/utils/alsa-utils-1.0.27.2.tar.bz2
URL:        http://alsa.cybermirror.org/utils
%description
 The ALSA Utilities package contains various utilities which are useful for controlling your sound card. 
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
./configure --disable-alsaconf --disable-xmlto &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/var/lib/alsa
make install DESTDIR=${RPM_BUILD_ROOT} 

touch ${RPM_BUILD_ROOT}/var/lib/alsa/asound.state &&

alsactl store
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-alsa DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
usermod -a -G audio mao
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog