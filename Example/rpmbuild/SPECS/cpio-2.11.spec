%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The cpio package contains tools for archiving. 
Name:       cpio
Version:    2.11
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/pub/gnu/cpio/cpio-2.11.tar.bz2
Source1:    ftp://ftp.gnu.org/pub/gnu/cpio/cpio-2.11.tar.bz2
URL:        http://ftp.gnu.org/pub/gnu/cpio
%description
 The cpio package contains tools for archiving. 
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
sed -i -e '/gets is a/d' gnu/stdio.in.h &&
./configure --prefix=/usr --bindir=/bin --enable-mt --with-rmt=/usr/libexec/rmt &&
make && %{?_smp_mflags} 

makeinfo --html            -o doc/html      doc/cpio.texi &&
makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi &&
makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/cpio-2.11
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/cpio-2.11/html
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/cpio-2.11/html &&

install -v -m644    doc/html/* ${RPM_BUILD_ROOT}/usr/share/doc/cpio-2.11/html &&

install -v -m644    doc/cpio.{html,txt} ${RPM_BUILD_ROOT}/usr/share/doc/cpio-2.11


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