%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     w3m is primarily a pager but it can also be used as a text-mode WWW browser. 
Name:       w3m
Version:    0.5.3
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  gc
Source0:    http://downloads.sourceforge.net/w3m/w3m-0.5.3.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/w3m-0.5.3-bdwgc72-1.patch
URL:        http://downloads.sourceforge.net/w3m
%description
 w3m is primarily a pager but it can also be used as a text-mode WWW browser. 
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
patch -Np1 -i %_sourcedir/w3m-0.5.3-bdwgc72-1.patch &&
sed -i 's/file_handle/file_foo/' istream.{c,h} &&
sed -i 's#gdk-pixbuf-xlib-2.0#& x11#' configure &&
./configure --prefix=/usr --sysconfdir=/etc &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/etc/w3m
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 -D doc/keymap.default ${RPM_BUILD_ROOT}/etc/w3m/keymap &&

install -v -m644    doc/menu.default ${RPM_BUILD_ROOT}/etc/w3m/menu &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/w3m-0.5.3 &&

install -v -m644    doc/{HISTORY,READ*,keymap.*,menu.*,*.html} ${RPM_BUILD_ROOT}/usr/share/doc/w3m-0.5.3


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