%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Common Unix Printing System (CUPS) is a print spooler and associated utilities. It is based on the "Internet Printing Protocol" and provides printing services to most PostScript and raster printers. 
Name:       cups
Version:    1.7.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  colord
Requires:  d-bus
Requires:  libusb
Source0:    http://www.cups.org/software/1.7.1/cups-1.7.1-source.tar.bz2
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/cups-1.7.1-blfs-1.patch
Source2:    http://www.linuxfromscratch.org/patches/blfs/7.5/cups-1.7.1-content_type-1.patch
URL:        http://www.cups.org/software/1.7.1
%description
 The Common Unix Printing System (CUPS) is a print spooler and associated utilities. It is based on the "Internet Printing Protocol" and provides printing services to most PostScript and raster printers. 
%pre
useradd -c "Print Service User" -d /var/spool/cups -g lp -s /bin/false -u 9 lp || :

groupadd -g 19 lpadmin || :

usermod -a -G lpadmin mao || :
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
sed -i 's#@CUPS_HTMLVIEW@#firefox#' desktop/cups.desktop.in
patch -Np1 -i %_sourcedir/cups-1.7.1-content_type-1.patch
patch -Np1 -i %_sourcedir/cups-1.7.1-blfs-1.patch &&
aclocal -I config-scripts &&
autoconf -I config-scripts &&
CC=gcc ./configure --libdir=/usr/lib --with-rcdir=/tmp/cupsinit --with-docdir=/usr/share/cups/doc --with-system-groups=lpadmin      &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/tmp
mkdir -pv ${RPM_BUILD_ROOT}/etc/cups
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/cups
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/cups/data
mkdir -pv ${RPM_BUILD_ROOT}/var/run/cups
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

rm -rf ${RPM_BUILD_ROOT}/tmp/cupsinit &&

ln -svfn ../cups/doc ${RPM_BUILD_ROOT}/usr/share/doc/cups-1.7.1

echo "ServerName ${RPM_BUILD_ROOT}/var/run/cups/cups.sock" > ${RPM_BUILD_ROOT}/etc/cups/client.conf

rm -rf ${RPM_BUILD_ROOT}/usr/share/cups/banners &&

rm -rf ${RPM_BUILD_ROOT}/usr/share/cups/data/testprint

mkdir -pv ${RPM_BUILD_ROOT}/etc

mkdir -pv ${SOURCES}/blfs-boot-scripts
cd ${SOURCES}/blfs-boot-scripts
tar xf  %_sourcedir/blfs-bootscripts-20140301.tar.bz2  --strip-components 1
make install-cups DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
gtk-update-icon-cache
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog