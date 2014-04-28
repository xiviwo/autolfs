%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Pidgin is a Gtk+ 2 instant messaging client that can connect with a wide range of networks including AIM, ICQ, GroupWise, MSN, Jabber, IRC, Napster, Gadu-Gadu, SILC, Zephyr and Yahoo! 
Name:       pidgin
Version:    2.10.7
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  gtk
Requires:  xml-parser
Requires:  libgcrypt
Requires:  gnutls
Source0:    http://downloads.sourceforge.net/pidgin/pidgin-2.10.7.tar.bz2
URL:        http://downloads.sourceforge.net/pidgin
%description
 Pidgin is a Gtk+ 2 instant messaging client that can connect with a wide range of networks including AIM, ICQ, GroupWise, MSN, Jabber, IRC, Napster, Gadu-Gadu, SILC, Zephyr and Yahoo! 
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
./configure --prefix=/usr --sysconfdir=/etc --disable-avahi --disable-dbus --disable-gtkspell --disable-gstreamer --disable-meanwhile --disable-idn --disable-nm --disable-vv --disable-tcl 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install  DESTDIR=${RPM_BUILD_ROOT} 

mkdir -pv -pv ${RPM_BUILD_ROOT}/usr/share/doc/pidgin-2.10.7 

cp -v README doc/gtkrc-2.0 ${RPM_BUILD_ROOT}/usr/share/doc/pidgin-2.10.7


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