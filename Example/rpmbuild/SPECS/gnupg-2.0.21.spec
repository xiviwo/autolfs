%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GnuPG 2 package is GNU's tool for secure communication and data storage. It can be used to encrypt data and to create digital signatures. It includes an advanced key management facility and is compliant with the proposed OpenPGP Internet standard as described in RFC2440 and the S/MIME standard as described by several RFCs. GnuPG 2 is the stable version of GnuPG integrating support for OpenPGP and S/MIME. It does not conflict with an installed GnuPG-1.4.14 OpenPGP-only version. 
Name:       gnupg
Version:    2.0.21
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  pth
Requires:  libassuan
Requires:  libgcrypt
Requires:  libksba
Requires:  pin-entry
Source0:    ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.21.tar.bz2
URL:        ftp://ftp.gnupg.org/gcrypt/gnupg
%description
 The GnuPG 2 package is GNU's tool for secure communication and data storage. It can be used to encrypt data and to create digital signatures. It includes an advanced key management facility and is compliant with the proposed OpenPGP Internet standard as described in RFC2440 and the S/MIME standard as described by several RFCs. GnuPG 2 is the stable version of GnuPG integrating support for OpenPGP and S/MIME. It does not conflict with an installed GnuPG-1.4.14 OpenPGP-only version. 
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
./configure --prefix=/usr --libexecdir=/usr/lib/gnupg2 --docdir=/usr/share/doc/gnupg-2.0.21 
make %{?_smp_mflags} 

makeinfo --html --no-split -o doc/gnupg_nochunks.html doc/gnupg.texi 
makeinfo --plaintext       -o doc/gnupg.txt           doc/gnupg.texi

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gnupg-2.0.21
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gnupg-2.0.21/html
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/gnupg-2.0.21/html 

install -v -m644    doc/gnupg_nochunks.html ${RPM_BUILD_ROOT}/usr/share/doc/gnupg-2.0.21/gnupg.html 

install -v -m644    doc/*.texi doc/gnupg.txt ${RPM_BUILD_ROOT}/usr/share/doc/gnupg-2.0.21


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