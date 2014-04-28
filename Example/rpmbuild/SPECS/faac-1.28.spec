%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     FAAC is an encoder for a lossy sound compression scheme specified in MPEG-2 Part 7 and MPEG-4 Part 3 standards and known as Advanced Audio Coding (AAC). This encoder is useful for producing files that can be played back on iPod. Moreover, iPod does not understand other sound compression schemes in video files. 
Name:       faac
Version:    1.28
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/faac/faac-1.28.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/faac-1.28-glibc_fixes-1.patch
URL:        http://downloads.sourceforge.net/faac
%description
 FAAC is an encoder for a lossy sound compression scheme specified in MPEG-2 Part 7 and MPEG-4 Part 3 standards and known as Advanced Audio Coding (AAC). This encoder is useful for producing files that can be played back on iPod. Moreover, iPod does not understand other sound compression schemes in video files. 
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
patch -Np1 -i %_sourcedir/faac-1.28-glibc_fixes-1.patch &&
sed -i -e '/obj-type/d' -e '/Long Term/d' frontend/main.c &&
./configure --prefix=/usr --disable-static &&
make %{?_smp_mflags} 
./frontend/faac -o Front_Left.mp4 /usr/share/sounds/alsa/Front_Left.wav
faad Front_Left.mp4
aplay Front_Left.wav

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