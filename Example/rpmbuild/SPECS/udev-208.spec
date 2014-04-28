%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Udev package contains programs for dynamic creation of device nodes. The development of udev has been merged with systemd, but most of systemd is incompatible with LFS. Here we build and install just the needed udev files. 
Name:       udev
Version:    208
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.freedesktop.org/software/systemd/systemd-208.tar.xz

URL:        http://www.freedesktop.org/software/systemd
%description
 The Udev package contains programs for dynamic creation of device nodes. The development of udev has been merged with systemd, but most of systemd is incompatible with LFS. Here we build and install just the needed udev files. 
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
tar -xvf  %_sourcedir/udev-lfs-208-3.tar.bz2
ln -svf /tools/include/blkid /usr/include
ln -svf /tools/include/uuid  /usr/include
export LD_LIBRARY_PATH=/tools/lib
make -f udev-lfs-208-3/Makefile.lfs %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/include/
make -f udev-lfs-208-3/Makefile.lfs install DESTDIR=${RPM_BUILD_ROOT} 

bash udev-lfs-208-3/init-net-rules.sh
rm -fv ${RPM_BUILD_ROOT}/usr/include/{uuid,blkid}

unset LD_LIBRARY_PATH

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
build/udevadm hwdb --update
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog