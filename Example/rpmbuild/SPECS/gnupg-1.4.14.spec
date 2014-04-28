%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GnuPG package contains a public/private key encryptor. This is useful for signing files or emails as proof of identity and preventing tampering with the contents of the file or email. For a more enhanced version of GnuPG which supports S/MIME, see the GnuPG-2.0.21 package. 
Name:       gnupg
Version:    1.4.14
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://anduin.linuxfromscratch.org/sources/BLFS/svn/g/gnupg-1.4.14.tar.bz2
Source1:    ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.14.tar.bz2
URL:        http://anduin.linuxfromscratch.org/sources/BLFS/svn/g
%description
 The GnuPG package contains a public/private key encryptor. This is useful for signing files or emails as proof of identity and preventing tampering with the contents of the file or email. For a more enhanced version of GnuPG which supports S/MIME, see the GnuPG-2.0.21 package. 
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
./configure --prefix=/usr --libexecdir=/usr/lib 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gnupg
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gnupg-1.4.14
make install  DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/gnupg-1.4.14 

cp      -v          ${RPM_BUILD_ROOT}/usr/share/gnupg/FAQ ${RPM_BUILD_ROOT}/usr/share/doc/gnupg-1.4.14 

install -v -m644    doc/{highlights-1.4.txt,OpenPGP,samplekeys.asc,DETAILS} ${RPM_BUILD_ROOT}/usr/share/doc/gnupg-1.4.14


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