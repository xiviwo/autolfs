%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The JasPer Project is an open-source initiative to provide a free software-based reference implementation of the JPEG-2000 codec. 
Name:       jasper
Version:    1.900.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  unzip
Requires:  libjpeg-turbo
Source0:    http://www.ece.uvic.ca/~mdadams/jasper/software/jasper-1.900.1.zip
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/jasper-1.900.1-security_fixes-1.patch
URL:        http://www.ece.uvic.ca/~mdadams/jasper/software
%description
 The JasPer Project is an open-source initiative to provide a free software-based reference implementation of the JPEG-2000 codec. 
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
patch -Np1 -i %_sourcedir/jasper-1.900.1-security_fixes-1.patch &&
./configure --prefix=/usr --enable-shared --disable-static --mandir=/usr/share/man &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/jasper-1.900.1 &&

install -v -m644 doc/*.pdf ${RPM_BUILD_ROOT}/usr/share/doc/jasper-1.900.1


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