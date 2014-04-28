%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The tree application, as the name suggests, is useful to display, in a terminal, directory contents, including directories, files, links. 
Name:       tree
Version:    1.6.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://mama.indstate.edu/users/ice/tree/src/tree-1.6.0.tgz
Source1:    ftp://mama.indstate.edu/linux/tree/tree-1.6.0.tgz
URL:        http://mama.indstate.edu/users/ice/tree/src
%description
 The tree application, as the name suggests, is useful to display, in a terminal, directory contents, including directories, files, links. 
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
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make MANDIR=${RPM_BUILD_ROOT}/usr/share/man/man1 install DESTDIR=${RPM_BUILD_ROOT} 


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