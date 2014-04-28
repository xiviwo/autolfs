%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Soprano (formally known as QRDF) is a library which provides a nice Qt interface to RDF storage solutions. It has a modular structure which allows to replace the actual RDF storage implementation used. 
Name:       soprano
Version:    2.9.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  cmake
Requires:  qt
Requires:  redland
Requires:  clucene
Requires:  d-bus
Requires:  libiodbc
Requires:  virtuoso
Source0:    http://downloads.sourceforge.net/soprano/soprano-2.9.4.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/soprano-2.9.4-dbus-1.patch
URL:        http://downloads.sourceforge.net/soprano
%description
 Soprano (formally known as QRDF) is a library which provides a nice Qt interface to RDF storage solutions. It has a modular structure which allows to replace the actual RDF storage implementation used. 
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
patch -Np1 -i %_sourcedir/soprano-2.9.4-dbus-1.patch &&
mkdir -pv build &&
cd    build &&
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd    build &&

mkdir -pv ${RPM_BUILD_ROOT}/srv
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/etc/sysconfig
make install DESTDIR=${RPM_BUILD_ROOT} 

install -m755 -d ${RPM_BUILD_ROOT}/srv/soprano

cat > /etc/sysconfig/soprano <<EOF
# Begin /etc/sysconfig/soprano
SOPRANO_STORAGE="/srv/soprano"
SOPRANO_BACKEND="virtuoso"                       # virtuoso, sesame2, redland
#SOPRANO_OPTIONS="$SOPRANO_OPTIONS --port 4711"  # Default port is 5000
# End /etc/sysconfig/soprano
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-soprano DESTDIR=${RPM_BUILD_ROOT} 


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