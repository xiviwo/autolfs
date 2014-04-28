%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The libIDL package contains libraries for Interface Definition Language files. This is a specification for defining portable interfaces. 
Name:       libidl
Version:    0.8.14
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  glib
Source0:    http://ftp.gnome.org/pub/gnome/sources/libIDL/0.8/libIDL-0.8.14.tar.bz2
Source1:    ftp://ftp.gnome.org/pub/gnome/sources/libIDL/0.8/libIDL-0.8.14.tar.bz2
URL:        http://ftp.gnome.org/pub/gnome/sources/libIDL/0.8
%description
 The libIDL package contains libraries for Interface Definition Language files. This is a specification for defining portable interfaces. 
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
./configure --prefix=/usr 
make %{?_smp_mflags} 

makeinfo --plaintext -o libIDL2.txt libIDL2.texi

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/libIDL-0.8.14 

install -v -m644    README libIDL2.{txt,texi} ${RPM_BUILD_ROOT}/usr/share/doc/libIDL-0.8.14


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