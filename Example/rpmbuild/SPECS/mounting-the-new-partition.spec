%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    mounting-the-new-partition
Name:       mounting-the-new-partition
Version:    1.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/lfs/view/stable/chapter02/mounting.html
%description
mounting-the-new-partition
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

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/dev
export LFS=${RPM_BUILD_ROOT}/mnt/lfs
mkdir -pv $LFS
mount -v -t ext3 ${RPM_BUILD_ROOT}/dev/vdb1 $LFS

mkdir -pv $LFS
mount -v -t ext3 ${RPM_BUILD_ROOT}/dev/vdb1 $LFS

mount -v -t ext3 ${RPM_BUILD_ROOT}/dev/vdb1 $LFS/usr

/sbin/swapon -v ${RPM_BUILD_ROOT}/dev/vdb2


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