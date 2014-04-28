%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The CDParanoia package contains a CD audio extraction tool. This is useful for extracting .wav files from audio CDs. A CDDA capable CDROM drive is needed. Practically all drives supported by Linux can be used. 
Name:       cdparanoia-iii
Version:    10.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.xiph.org/releases/cdparanoia/cdparanoia-III-10.2.src.tgz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/cdparanoia-III-10.2-gcc_fixes-1.patch
URL:        http://downloads.xiph.org/releases/cdparanoia
%description
 The CDParanoia package contains a CD audio extraction tool. This is useful for extracting .wav files from audio CDs. A CDDA capable CDROM drive is needed. Practically all drives supported by Linux can be used. 
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
patch -Np1 -i %_sourcedir/cdparanoia-III-10.2-gcc_fixes-1.patch &&
./configure --prefix=/usr --mandir=/usr/share/man &&
make -j1 %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install && DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libcdda_*.so.0.10.2
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog