%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libmpeg2 package contains a library for decoding MPEG-2 and MPEG-1 video streams. The library is able to decode all MPEG streams that conform to certain restrictions: “constrained parameters” for MPEG-1, and “main profile” for MPEG-2. This is useful for programs and applications needing to decode MPEG-2 and MPEG-1 video streams. 
Name:       libmpeg2
Version:    0.5.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://libmpeg2.sourceforge.net/files/libmpeg2-0.5.1.tar.gz
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/libmpeg2-0.5.1.tar.gz
URL:        http://libmpeg2.sourceforge.net/files
%description
 The libmpeg2 package contains a library for decoding MPEG-2 and MPEG-1 video streams. The library is able to decode all MPEG streams that conform to certain restrictions: “constrained parameters” for MPEG-1, and “main profile” for MPEG-2. This is useful for programs and applications needing to decode MPEG-2 and MPEG-1 video streams. 
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
sed -i 's/static const/static/' libmpeg2/idct_mmx.c &&
./configure --prefix=/usr                           &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/mpeg2dec-0.5.1 &&

install -v -m644 README doc/libmpeg2.txt ${RPM_BUILD_ROOT}/usr/share/doc/mpeg2dec-0.5.1


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