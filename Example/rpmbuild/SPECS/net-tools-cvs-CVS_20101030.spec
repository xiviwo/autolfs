%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Net-tools package is a collection of programs for controlling the network subsystem of the Linux kernel. 
Name:       net-tools-cvs
Version:    CVS_20101030
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://anduin.linuxfromscratch.org/sources/BLFS/svn/n/net-tools-CVS_20101030.tar.gz
Source1:    ftp://anduin.linuxfromscratch.org/BLFS/svn/n/net-tools-CVS_20101030.tar.gz
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/net-tools-CVS_20101030-remove_dups-1.patch
URL:        http://anduin.linuxfromscratch.org/sources/BLFS/svn/n
%description
 The Net-tools package is a collection of programs for controlling the network subsystem of the Linux kernel. 
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


patch -Np1 -i ../net-tools-CVS_20101030-remove_dups-1.patch &&
yes "" | make config &&
make
make update

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