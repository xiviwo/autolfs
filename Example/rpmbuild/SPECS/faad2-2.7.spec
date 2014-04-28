%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     FAAD2 is a decoder for a lossy sound compression scheme specified in MPEG-2 Part 7 and MPEG-4 Part 3 standards and known as Advanced Audio Coding (AAC). 
Name:       faad2
Version:    2.7
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/faac/faad2-2.7.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/faad2-2.7-mp4ff-1.patch
Source2:    http://www.nch.com.au/acm/sample.aac
URL:        http://downloads.sourceforge.net/faac
%description
 FAAD2 is a decoder for a lossy sound compression scheme specified in MPEG-2 Part 7 and MPEG-4 Part 3 standards and known as Advanced Audio Coding (AAC). 
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
patch -Np1 -i %_sourcedir/faad2-2.7-mp4ff-1.patch &&
sed -i "s:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:g" configure.in &&
sed -i "s:man_MANS:man1_MANS:g" frontend/Makefile.am &&
autoreconf -fi &&
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 
./frontend/faad -o sample.wav ../sample.aac
aplay sample.wav

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make install DESTDIR=${RPM_BUILD_ROOT} 


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