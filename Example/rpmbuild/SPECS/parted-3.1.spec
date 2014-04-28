%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Parted package is a disk partitioning and partition resizing tool. 
Name:       parted
Version:    3.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  lvm2
Source0:    http://ftp.gnu.org/gnu/parted/parted-3.1.tar.xz
URL:        http://ftp.gnu.org/gnu/parted
%description
 The Parted package is a disk partitioning and partition resizing tool. 
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
./configure --prefix=/usr --disable-static &&
make && %{?_smp_mflags} 

make -C doc html                                       && %{?_smp_mflags} 

makeinfo --html      -o doc/html       doc/parted.texi &&
makeinfo --plaintext -o doc/parted.txt doc/parted.texi

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/parted-3.1
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/parted-3.1/html
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/parted-3.1/html &&

install -v -m644    doc/html/* ${RPM_BUILD_ROOT}/usr/share/doc/parted-3.1/html &&

install -v -m644    doc/{FAT,API,parted.{txt,html}} ${RPM_BUILD_ROOT}/usr/share/doc/parted-3.1


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