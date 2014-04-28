%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Avahi package is a system which facilitates service discovery on a local network. 
Name:       avahi
Version:    0.6.31
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  intltool
Source0:    http://avahi.org/download/avahi-0.6.31.tar.gz
URL:        http://avahi.org/download
%description
 The Avahi package is a system which facilitates service discovery on a local network. 
%pre
groupadd -fg 84 avahi  || :

useradd -c "Avahi Daemon Owner" -d /var/run/avahi-daemon -u 84 -g avahi -s /bin/false avahi || :

groupadd -fg 86 netdev || :
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
sed -i 's/\(CFLAGS=.*\)-Werror \(.*\)/\1\2/' configure &&
sed -i -e 's/-DG_DISABLE_DEPRECATED=1//' -e '/-DGDK_DISABLE_DEPRECATED/d' avahi-ui/Makefile.in &&
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-static --disable-mono --disable-monodoc --disable-python --disable-qt3 --disable-qt4 --enable-core-docs --with-distro=none &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
make install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-avahi DESTDIR=${RPM_BUILD_ROOT} 


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