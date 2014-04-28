%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Groff package contains programs for processing and formatting text. 
Name:       groff
Version:    1.22.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/groff/groff-1.22.2.tar.gz

URL:        http://ftp.gnu.org/gnu/groff
%description
 The Groff package contains programs for processing and formatting text. 
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
PAGE=A4 ./configure --prefix=/usr
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make install DESTDIR=${RPM_BUILD_ROOT} 

ln -svf eqn ${RPM_BUILD_ROOT}/usr/bin/geqn

ln -svf tbl ${RPM_BUILD_ROOT}/usr/bin/gtbl


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