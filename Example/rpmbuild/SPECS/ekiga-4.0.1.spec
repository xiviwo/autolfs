%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Ekiga is a VoIP, IP Telephony, and Video Conferencing application that allows you to make audio and video calls to remote users with SIP or H.323 compatible hardware and software. It supports many audio and video codecs and all modern VoIP features for both SIP and H.323. Ekiga is the first Open Source application to support both H.323 and SIP, as well as audio and video. 
Name:       ekiga
Version:    4.0.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  boost
Requires:  gnome-icon-theme
Requires:  gtk
Requires:  opal
Requires:  dbus-glib
Requires:  gconf
Requires:  libnotify
Source0:    http://ftp.gnome.org/pub/gnome/sources/ekiga/4.0/ekiga-4.0.1.tar.xz
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/ekiga/4.0/ekiga-4.0.1.tar.xz
URL:        http://ftp.gnome.org/pub/gnome/sources/ekiga/4.0
%description
 Ekiga is a VoIP, IP Telephony, and Video Conferencing application that allows you to make audio and video calls to remote users with SIP or H.323 compatible hardware and software. It supports many audio and video codecs and all modern VoIP features for both SIP and H.323. Ekiga is the first Open Source application to support both H.323 and SIP, as well as audio and video. 
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
./configure --prefix=/usr --sysconfdir=/etc --disable-eds --disable-gdu --disable-ldap --disable-scrollkeeper &&
make %{?_smp_mflags} 

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