%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Grep package contains programs for searching through files. 
Name:       grep
Version:    2.14
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/grep/grep-2.14.tar.xz

URL:        http://ftp.gnu.org/gnu/grep
%description
 The Grep package contains programs for searching through files. 
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
./configure --prefix=/usr --bindir=/bin
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=$RPM_BUILD_ROOT 


[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
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