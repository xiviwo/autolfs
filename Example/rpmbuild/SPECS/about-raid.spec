export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:    about-raid
Name:       about-raid
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools


URL:        http://www.linuxfromscratch.org/blfs/view/stable/postlfs/raid.html
%description
about-raid
%pre
%prep
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

mkdir -pv $RPM_BUILD_ROOT/dev
/sbin/mdadm -Cv ${RPM_BUILD_ROOT}/dev/md0 --level=1 --raid-devices=2 ${RPM_BUILD_ROOT}/dev/sda1 ${RPM_BUILD_ROOT}/dev/sdb1
/sbin/mdadm -Cv ${RPM_BUILD_ROOT}/dev/md1 --level=1 --raid-devices=2 ${RPM_BUILD_ROOT}/dev/sda2 ${RPM_BUILD_ROOT}/dev/sdb2
/sbin/mdadm -Cv ${RPM_BUILD_ROOT}/dev/md3 --level=0 --raid-devices=2 ${RPM_BUILD_ROOT}/dev/sdc1 ${RPM_BUILD_ROOT}/dev/sdd1
/sbin/mdadm -Cv ${RPM_BUILD_ROOT}/dev/md2 --level=5 --raid-devices=4 \
        ${RPM_BUILD_ROOT}/dev/sda4 ${RPM_BUILD_ROOT}/dev/sdb4 ${RPM_BUILD_ROOT}/dev/sdc2 ${RPM_BUILD_ROOT}/dev/sdd2

[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
%post
/sbin/ldconfig

/sbin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog