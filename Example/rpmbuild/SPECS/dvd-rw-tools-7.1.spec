%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The dvd+rw-tools package contains several utilities to master the DVD media, both +RW/+R and -R[W]. The principle tool is growisofs which provides a way to both lay down and grow an ISO9660 file system on (as well as to burn an arbitrary pre-mastered image to) all supported DVD media. This is useful for creating a new DVD or adding to an existing image on a partially burned DVD. 
Name:       dvd-rw-tools
Version:    7.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://fy.chalmers.se/~appro/linux/DVD+RW/tools/dvd+rw-tools-7.1.tar.gz
URL:        http://fy.chalmers.se/~appro/linux/DVD+RW/tools
%description
 The dvd+rw-tools package contains several utilities to master the DVD media, both +RW/+R and -R[W]. The principle tool is growisofs which provides a way to both lay down and grow an ISO9660 file system on (as well as to burn an arbitrary pre-mastered image to) all supported DVD media. This is useful for creating a new DVD or adding to an existing image on a partially burned DVD. 
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
sed -i '/stdlib/a #include <limits.h>' transport.hxx &&
sed -i 's#mkisofs"#xorrisofs"#' growisofs.c &&
sed -i 's#mkisofs#xorrisofs#;s#MKISOFS#XORRISOFS#' growisofs.1 &&
make all rpl8 btcflash %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/dvd+rw-tools-7.1
make prefix=${RPM_BUILD_ROOT}/usr install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 -D index.html ${RPM_BUILD_ROOT}/usr/share/doc/dvd+rw-tools-7.1/index.html


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