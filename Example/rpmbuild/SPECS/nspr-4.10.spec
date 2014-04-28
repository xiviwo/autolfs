%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Netscape Portable Runtime (NSPR) provides a platform-neutral API for system level and libc like functions. 
Name:       nspr
Version:    4.10
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v4.10/src/nspr-4.10.tar.gz
Source1:    ftp://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v4.10/src/nspr-4.10.tar.gz
URL:        http://ftp.mozilla.org/pub/mozilla.org/nspr/releases/v4.10/src
%description
 Netscape Portable Runtime (NSPR) provides a platform-neutral API for system level and libc like functions. 
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
cd nspr                                                     
sed -ri 's#^(RELEASE_BINS =).*#\1#' pr/src/misc/Makefile.in 
sed -i 's#$(LIBRARY) ##' config/rules.mk                    
./configure --prefix=/usr --with-mozilla --with-pthreads $([ $(uname -m) = x86_64 ] && echo --enable-64bit) 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd nspr                                                     


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