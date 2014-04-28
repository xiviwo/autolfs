%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libvorbis package contains a general purpose audio and music encoding format. This is useful for creating (encoding) and playing (decoding) sound in an open (patent free) format. 
Name:       libvorbis
Version:    1.3.3
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  libogg
Source0:    http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.3.tar.xz
URL:        http://downloads.xiph.org/releases/vorbis
%description
 The libvorbis package contains a general purpose audio and music encoding format. This is useful for creating (encoding) and playing (decoding) sound in an open (patent free) format. 
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
./configure --prefix=/usr --disable-static 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/libvorbis-1.3.3
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 doc/Vorbis* ${RPM_BUILD_ROOT}/usr/share/doc/libvorbis-1.3.3


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