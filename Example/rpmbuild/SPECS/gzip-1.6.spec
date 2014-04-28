%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Gzip package contains programs for compressing and decompressing files. 
Name:       gzip
Version:    1.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/gzip/gzip-1.6.tar.xz

URL:        http://ftp.gnu.org/gnu/gzip
%description
 The Gzip package contains programs for compressing and decompressing files. 
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

mkdir -pv ${RPM_BUILD_ROOT}/bin/
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make install DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/bin/{gzexe,uncompress,zcmp,zdiff,zegrep} ${RPM_BUILD_ROOT}/usr/bin

mv -v ${RPM_BUILD_ROOT}/bin/{zfgrep,zforce,zgrep,zless,zmore,znew} ${RPM_BUILD_ROOT}/usr/bin


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