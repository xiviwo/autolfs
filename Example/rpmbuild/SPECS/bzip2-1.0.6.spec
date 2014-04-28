%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Bzip2 package contains programs for compressing and decompressing files. Compressing text files with bzip2 yields a much better compression percentage than with the traditional gzip. 
Name:       bzip2
Version:    1.0.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz

URL:        http://www.bzip.org/1.0.6
%description
 The Bzip2 package contains programs for compressing and decompressing files. Compressing text files with bzip2 yields a much better compression percentage than with the traditional gzip. 
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
patch -Np1 -i %_sourcedir/bzip2-1.0.6-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so %{?_smp_mflags} 

make clean %{?_smp_mflags} 

make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin/
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/bin
make PREFIX=${RPM_BUILD_ROOT}/usr install DESTDIR=${RPM_BUILD_ROOT} 

cp -v bzip2-shared ${RPM_BUILD_ROOT}/bin/bzip2

cp -av libbz2.so* ${RPM_BUILD_ROOT}/lib

ln -svf  %_sourcedir/../lib/libbz2.so.1.0 ${RPM_BUILD_ROOT}/usr/lib/libbz2.so

rm -v ${RPM_BUILD_ROOT}/usr/bin/{bunzip2,bzcat,bzip2}

ln -svf bzip2 ${RPM_BUILD_ROOT}/bin/bunzip2

ln -svf bzip2 ${RPM_BUILD_ROOT}/bin/bzcat


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