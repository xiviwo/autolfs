%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The xine User Interface package contains a multimedia player. It plays back CDs, DVDs and VCDs. It also decodes multimedia files like AVI, MOV, WMV, MPEG and MP3 from local disk drives, and displays multimedia streamed over the Internet. 
Name:       xine-ui
Version:    0.99.7
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  xine-lib
Requires:  shared-mime-info
Source0:    http://downloads.sourceforge.net/xine/xine-ui-0.99.7.tar.xz
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xine-ui-0.99.7.tar.xz
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/xine-ui-0.99.7-upstream_fix-1.patch
URL:        http://downloads.sourceforge.net/xine
%description
 The xine User Interface package contains a multimedia player. It plays back CDs, DVDs and VCDs. It also decodes multimedia files like AVI, MOV, WMV, MPEG and MP3 from local disk drives, and displays multimedia streamed over the Internet. 
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
patch -Np1 -i %_sourcedir/xine-ui-0.99.7-upstream_fix-1.patch
./configure --prefix=/usr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}


make docsdir=${RPM_BUILD_ROOT}/usr/share/doc/xine-ui-0.99.7 install DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
gtk-update-icon-cache &&

update-desktop-database
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog