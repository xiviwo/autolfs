%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The NcFTP package contains a powerful and flexible interface to the Internet standard File Transfer Protocol. It is intended to replace or supplement the stock ftp program. 
Name:       ncftp
Version:    3.2.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    ftp://ftp.ncftp.com/ncftp/ncftp-3.2.5-src.tar.bz2
URL:        ftp://ftp.ncftp.com/ncftp
%description
 The NcFTP package contains a powerful and flexible interface to the Internet standard File Transfer Protocol. It is intended to replace or supplement the stock ftp program. 
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
./configure --prefix=/usr --sysconfdir=/etc &&
make -C libncftp shared && %{?_smp_mflags} 

make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make -C libncftp soinstall && DESTDIR=${RPM_BUILD_ROOT} 

make install DESTDIR=${RPM_BUILD_ROOT} 

./configure --prefix=${RPM_BUILD_ROOT}/usr --sysconfdir=${RPM_BUILD_ROOT}/etc &&
make
make install DESTDIR=${RPM_BUILD_ROOT} 


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