%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Udev package contains programs for dynamic creation of device nodes. The development of udev has been merged with systemd, but most of systemd is incompatible with LFS. Here we build and install just the needed udev files. 
Name:       udev
Version:    206
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.freedesktop.org/software/systemd/systemd-206.tar.xz

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
tar -xvf  %_sourcedir/udev-lfs-206-1.tar.bz2
make -f udev-lfs-206-1/Makefile.lfs %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make -f udev-lfs-206-1/Makefile.lfs install DESTDIR=$RPM_BUILD_ROOT 

mkdir -pv $RPM_BUILD_ROOT/etc/udev/rules.d/
cp -v /etc/udev/rules.d/70-persistent-net.rules $RPM_BUILD_ROOT/etc/udev/rules.d/
sed -i 's/"00:0c:29:[^\".]*"/"00:0c:29:*:*:*"/' $RPM_BUILD_ROOT/etc/udev/rules.d/70-persistent-net.rules

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
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