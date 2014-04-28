%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Guile package contains the Project GNU's extension language library. Guile also contains a stand alone Scheme interpreter. 
Name:       guile
Version:    2.0.9
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gc
Requires:  libffi
Requires:  libunistring
Source0:    http://ftp.gnu.org/pub/gnu/guile/guile-2.0.9.tar.xz
Source1:    ftp://ftp.gnu.org/pub/gnu/guile/guile-2.0.9.tar.xz
URL:        http://ftp.gnu.org/pub/gnu/guile
%description
 The Guile package contains the Project GNU's extension language library. Guile also contains a stand alone Scheme interpreter. 
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
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/guile-2.0.9 &&
make      && %{?_smp_mflags} 

make html && %{?_smp_mflags} 

makeinfo --plaintext -o doc/r5rs/r5rs.txt doc/r5rs/r5rs.texi &&
makeinfo --plaintext -o doc/ref/guile.txt doc/ref/guile.texi

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/guile-2.0.9
make install      && DESTDIR=${RPM_BUILD_ROOT} 

make install-html && DESTDIR=${RPM_BUILD_ROOT} 

mv ${RPM_BUILD_ROOT}/usr/share/doc/guile-2.0.9/{guile.html,ref} &&

mv ${RPM_BUILD_ROOT}/usr/share/doc/guile-2.0.9/r5rs{.html,}     &&

find examples -name "Makefile*" -delete &&
cp -vR examples   ${RPM_BUILD_ROOT}/usr/share/doc/guile-2.0.9   &&

for DIRNAME in r5rs ref; do
  install -v -m644  doc/${DIRNAME}/*.txt ${RPM_BUILD_ROOT}/usr/share/doc/guile-2.0.9/${DIRNAME}

done &&
unset DIRNAME

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