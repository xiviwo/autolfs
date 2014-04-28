%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The cURL package contains a utility and a library used for transferring files with URL syntax to any of the following protocols: FTP, FTPS, HTTP, HTTPS, SCP, SFTP, TFTP, TELNET, DICT, LDAP, LDAPS and FILE. Its ability to both download and upload files can be incorporated into other programs to support functions like streaming media. 
Name:       curl
Version:    7.35.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  certificate-authority-certificates
Requires:  openssl
Source0:    http://curl.haxx.se/download/curl-7.35.0.tar.bz2
URL:        http://curl.haxx.se/download
%description
 The cURL package contains a utility and a library used for transferring files with URL syntax to any of the following protocols: FTP, FTPS, HTTP, HTTPS, SCP, SFTP, TFTP, TELNET, DICT, LDAP, LDAPS and FILE. Its ability to both download and upload files can be incorporated into other programs to support functions like streaming media. 
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
./configure --prefix=/usr --disable-static --enable-threaded-resolver &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

find docs \( -name "Makefile*" -o -name "*.1" -o -name "*.3" \) -exec rm {} \; &&
install -v -d -m755 ${RPM_BUILD_ROOT}/usr/share/doc/curl-7.35.0 &&

cp -v -R docs/*     ${RPM_BUILD_ROOT}/usr/share/doc/curl-7.35.0


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