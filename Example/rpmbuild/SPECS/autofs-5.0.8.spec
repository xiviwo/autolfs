%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Autofs controls the operation of the automount daemons. The automount daemons automatically mount filesystems when they are accessed and unmount them after a period of inactivity. This is done based on a set of pre-configured maps. 
Name:       autofs
Version:    5.0.8
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.kernel.org/pub/linux/daemons/autofs/v5/autofs-5.0.8.tar.xz
Source1:    ftp://ftp.kernel.org/pub/linux/daemons/autofs/v5/autofs-5.0.8.tar.xz
URL:        http://ftp.kernel.org/pub/linux/daemons/autofs/v5
%description
 Autofs controls the operation of the automount daemons. The automount daemons automatically mount filesystems when they are accessed and unmount them after a period of inactivity. This is done based on a set of pre-configured maps. 
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
./configure --prefix=/ --mandir=/usr/share/man &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
make install DESTDIR=${RPM_BUILD_ROOT} 

mv ${RPM_BUILD_ROOT}/etc/auto.master ${RPM_BUILD_ROOT}/etc/auto.master.bak &&

cat > /etc/auto.master << "EOF"
# Begin /etc/auto.master
/media/auto  /etc/auto.misc  --ghost
#/home        /etc/auto.home
# End /etc/auto.master
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-autofs DESTDIR=${RPM_BUILD_ROOT} 


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