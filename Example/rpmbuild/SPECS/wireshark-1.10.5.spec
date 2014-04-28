%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Wireshark package contains a network protocol analyzer, also known as a “sniffer”. This is useful for analyzing data captured “off the wire” from a live network connection, or data read from a capture file. Wireshark provides both a graphical and a TTY-mode front-end for examining captured network packets from over 500 protocols, as well as the capability to read capture files from many other popular network analyzers. 
Name:       wireshark
Version:    1.10.5
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Requires:  libpcap
Source0:    http://www.wireshark.org/download/src/all-versions/wireshark-1.10.5.tar.bz2
URL:        http://www.wireshark.org/download/src/all-versions
%description
 The Wireshark package contains a network protocol analyzer, also known as a “sniffer”. This is useful for analyzing data captured “off the wire” from a live network connection, or data read from a capture file. Wireshark provides both a graphical and a TTY-mode front-end for examining captured network packets from over 500 protocols, as well as the capability to read capture files from many other popular network analyzers. 
%pre
groupadd -g 62 wireshark || :
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
cat > svnversion.h << "EOF"
#define SVNVERSION "BLFS"
#define SVNPATH "source"
EOF
cat > make-version.pl << "EOF"
#!/usr/bin/perl
EOF
./configure --prefix=/usr --sysconfdir=/etc &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin/
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/applications
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/pixmaps
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/wireshark-1.10.5 &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/pixmaps/wireshark &&

install -v -m644    README{,.linux} doc/README.* doc/*.{pod,txt} ${RPM_BUILD_ROOT}/usr/share/doc/wireshark-1.10.5 &&

pushd ${RPM_BUILD_ROOT}/usr/share/doc/wireshark-1.10.5 &&

   for FILENAME in ../../wireshark/*.html; do
      ln -svf -v -f $FILENAME .
   done &&
popd &&
install -v -m644 -D wireshark.desktop ${RPM_BUILD_ROOT}/usr/share/applications/wireshark.desktop &&

install -v -m644 -D image/wsicon48.png ${RPM_BUILD_ROOT}/usr/share/pixmaps/wireshark.png &&

install -v -m644    image/*.{png,ico,xpm,bmp} ${RPM_BUILD_ROOT}/usr/share/pixmaps/wireshark

install -v -m644 <Downloaded_Files> ${RPM_BUILD_ROOT}/usr/share/doc/wireshark-1.10.5


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -v root:wireshark /usr/bin/{tshark,dumpcap} &&

chmod -v 6550 /usr/bin/{tshark,dumpcap}
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog