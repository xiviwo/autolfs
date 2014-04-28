%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Cdrdao package contains CD recording utilities. These are useful for burning a CD in disk-at-once mode. 
Name:       cdrdao
Version:    1.2.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libao
Requires:  libvorbis
Requires:  libmad
Requires:  lame
Source0:    http://downloads.sourceforge.net/cdrdao/cdrdao-1.2.3.tar.bz2
URL:        http://downloads.sourceforge.net/cdrdao
%description
 The Cdrdao package contains CD recording utilities. These are useful for burning a CD in disk-at-once mode. 
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
sed -i '/ioctl/a #include <sys/stat.h>' dao/ScsiIf-linux.cc &&
./configure --prefix=/usr --mandir=/usr/share/man &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/cdrdao-1.2.3 &&

install -v -m644 README ${RPM_BUILD_ROOT}/usr/share/doc/cdrdao-1.2.3


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