%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GPM (General Purpose Mouse daemon) package contains a mouse server for the console and xterm. It not only provides cut and paste support generally, but its library component is used by various software such as Links to provide mouse support to the application. It is useful on desktops, especially if following (Beyond) Linux From Scratch instructions; it's often much easier (and less error prone) to cut and paste between two console windows than to type everything by hand! 
Name:       gpm
Version:    1.20.7
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.nico.schottelius.org/software/gpm/archives/gpm-1.20.7.tar.bz2
URL:        http://www.nico.schottelius.org/software/gpm/archives
%description
 The GPM (General Purpose Mouse daemon) package contains a mouse server for the console and xterm. It not only provides cut and paste support generally, but its library component is used by various software such as Links to provide mouse support to the application. It is useful on desktops, especially if following (Beyond) Linux From Scratch instructions; it's often much easier (and less error prone) to cut and paste between two console windows than to type everything by hand! 
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
./autogen.sh                                &&
./configure --prefix=/usr --sysconfdir=/etc &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/info
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gpm-1.20.7
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/etc/sysconfig
make install                                          && DESTDIR=${RPM_BUILD_ROOT} 

install-info --dir-file=${RPM_BUILD_ROOT}/usr/share/info/dir ${RPM_BUILD_ROOT}/usr/share/info/gpm.info                 &&

ln -sfv libgpm.so.2.1.0 ${RPM_BUILD_ROOT}/usr/lib/libgpm.so            &&

install -v -m644 conf/gpm-root.conf ${RPM_BUILD_ROOT}/etc              &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/gpm-1.20.7/support &&

install -v -m644    doc/support/* ${RPM_BUILD_ROOT}/usr/share/doc/gpm-1.20.7/support &&

install -v -m644    doc/{FAQ,HACK_GPM,README*} ${RPM_BUILD_ROOT}/usr/share/doc/gpm-1.20.7

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-gpm DESTDIR=${RPM_BUILD_ROOT} 

cat > /etc/sysconfig/mouse << "EOF"
# Begin /etc/sysconfig/mouse
MDEVICE="<yourdevice>"
PROTOCOL="<yourprotocol>"
GPMOPTS="<additional options>"
# End /etc/sysconfig/mouse
EOF

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