%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Kbd package contains key-table files, console fonts, and keyboard utilities. 
Name:       kbd
Version:    2.0.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.altlinux.org/pub/people/legion/kbd/kbd-2.0.1.tar.gz

URL:        http://ftp.altlinux.org/pub/people/legion/kbd
%description
 The Kbd package contains key-table files, console fonts, and keyboard utilities. 
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
patch -Np1 -i %_sourcedir/kbd-2.0.1-backspace-1.patch
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/kbd-2.0.1
make install DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv       ${RPM_BUILD_ROOT}/usr/share/doc/kbd-2.0.1

cp -R -v docs/doc/* ${RPM_BUILD_ROOT}/usr/share/doc/kbd-2.0.1


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