%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     libtheora is a reference implementation of the Theora video compression format being developed by the Xiph.Org Foundation. 
Name:       libtheora
Version:    1.1.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libogg
Requires:  libvorbis
Source0:    http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.xz
URL:        http://downloads.xiph.org/releases/theora
%description
 libtheora is a reference implementation of the Theora video compression format being developed by the Xiph.Org Foundation. 
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
sed -i 's/png_\(sizeof\)/\1/g' examples/png2theora.c &&
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make install DESTDIR=${RPM_BUILD_ROOT} 

cd examples/.libs &&
for E in *; do
  install -v -m755 $E ${RPM_BUILD_ROOT}/usr/bin/theora_${E}

done

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