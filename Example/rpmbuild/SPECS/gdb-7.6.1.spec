%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     GDB, the GNU Project debugger, allows you to see what is going on “inside” another program while it executes -- or what another program was doing at the moment it crashed. Note that GDB is most effective when tracing programs and libraries that were built with debugging symbols and not stripped. 
Name:       gdb
Version:    7.6.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/gdbm/gdbm-1.10.tar.gz

URL:        http://ftp.gnu.org/gnu/gdbm
%description
 GDB, the GNU Project debugger, allows you to see what is going on “inside” another program while it executes -- or what another program was doing at the moment it crashed. Note that GDB is most effective when tracing programs and libraries that were built with debugging symbols and not stripped. 
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
./configure --prefix=/usr 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make -C gdb install DESTDIR=${RPM_BUILD_ROOT} 


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