%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Nano package contains a small, simple text editor which aims to replace Pico, the default editor in the Pine package. 
Name:       nano
Version:    2.3.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/nano/nano-2.3.2.tar.gz
Source1:    ftp://ftp.gnu.org/gnu/nano/nano-2.3.2.tar.gz
URL:        http://ftp.gnu.org/gnu/nano
%description
 The Nano package contains a small, simple text editor which aims to replace Pico, the default editor in the Pine package. 
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
./configure --prefix=/usr --sysconfdir=/etc --enable-utf8 &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/nano-2.3.2
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m644 doc/nanorc.sample ${RPM_BUILD_ROOT}/etc &&

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/nano-2.3.2 &&

install -v -m644 doc/{,man/,texinfo/}*.html ${RPM_BUILD_ROOT}/usr/share/doc/nano-2.3.2


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