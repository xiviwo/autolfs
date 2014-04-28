%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The PCRE package contains Perl Compatible Regular Expression libraries. These are useful for implementing regular expression pattern matching using the same syntax and semantics as Perl 5. 
Name:       pcre
Version:    8.33
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://downloads.sourceforge.net/pcre/pcre-8.33.tar.bz2
Source1:    ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.33.tar.bz2
URL:        http://downloads.sourceforge.net/pcre
%description
 The PCRE package contains Perl Compatible Regular Expression libraries. These are useful for implementing regular expression pattern matching using the same syntax and semantics as Perl 5. 
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
./configure --prefix=/usr --docdir=/usr/share/doc/pcre-8.33 --enable-utf --enable-unicode-properties --enable-pcre16 --enable-pcre32 --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-pcretest-libreadline --disable-static                 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
make install                      DESTDIR=${RPM_BUILD_ROOT} 

mv -v ${RPM_BUILD_ROOT}/usr/lib/libpcre.so.* ${RPM_BUILD_ROOT}/lib 

ln -sfv ../../lib/$(readlink ${RPM_BUILD_ROOT}/usr/lib/libpcre.so) ${RPM_BUILD_ROOT}/usr/lib/libpcre.so


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