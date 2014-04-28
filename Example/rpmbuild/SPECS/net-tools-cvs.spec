%define dist BLFS
Summary:     The Net-tools package is a collection of programs for controlling the network subsystem of the Linux kernel. 
Name:       net-tools-cvs
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://anduin.linuxfromscratch.org/sources/BLFS/svn/n/net-tools-CVS_20101030.tar.gz
Source1:    ftp://anduin.linuxfromscratch.org/BLFS/svn/n/net-tools-CVS_20101030.tar.gz
URL:        http://anduin.linuxfromscratch.org/sources/BLFS/svn/n
%description
 The Net-tools package is a collection of programs for controlling the network subsystem of the Linux kernel. 
%pre
%prep
rm -rf %_builddir/%{name}-%{version}
mkdir -pv %_builddir/%{name}-%{version} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{name}-%{version}
	;;
	*tar)
	tar xf %SOURCE0 -C %{name}-%{version} 
	;;
	*)
	tar xf %SOURCE0 -C %{name}-%{version}  --strip-components 1
	;;
esac

%build
cd %_builddir/%{name}-%{version}

%install
cd %_builddir/%{name}-%{version}
rm -rf ${RPM_BUILD_ROOT}


sed -i -e '/Token/s/y$/n/'        config.in &&
sed -i -e '/HAVE_HWSTRIP/s/y$/n/' config.in &&
yes "" | make config                 &&
make
make update

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