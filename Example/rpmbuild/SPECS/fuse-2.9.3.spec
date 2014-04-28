%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     FUSE (Filesystem in Userspace) is a simple interface for userspace programs to export a virtual filesystem to the Linux kernel. Fuse also aims to provide a secure method for non privileged users to create and mount their own filesystem implementations. 
Name:       fuse
Version:    2.9.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/fuse/fuse-2.9.3.tar.gz
URL:        http://downloads.sourceforge.net/fuse
%description
 FUSE (Filesystem in Userspace) is a simple interface for userspace programs to export a virtual filesystem to the Linux kernel. Fuse also aims to provide a secure method for non privileged users to create and mount their own filesystem implementations. 
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
./configure --prefix=/usr --disable-static INIT_D_PATH=/tmp/init.d &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/fuse-2.9.3
mkdir -pv ${RPM_BUILD_ROOT}/tmp
make install && DESTDIR=${RPM_BUILD_ROOT} 

mv -v   ${RPM_BUILD_ROOT}/usr/lib/libfuse.so.* ${RPM_BUILD_ROOT}/lib &&

ln -sfv ../../lib/libfuse.so.2.9.3 ${RPM_BUILD_ROOT}/usr/lib/libfuse.so &&

rm -rf  ${RPM_BUILD_ROOT}/tmp/init.d &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/fuse-2.9.3 &&

install -v -m644    doc/{how-fuse-works,kernel.txt} ${RPM_BUILD_ROOT}/usr/share/doc/fuse-2.9.3

cat > /etc/fuse.conf << "EOF"
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#
#mount_max = 1000
# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
#
#user_allow_other
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