%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Aspell package contains an interactive spell checking program and the Aspell libraries. Aspell can either be used as a library or as an independent spell checker. 
Name:       aspell
Version:    0.60.6.1
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  which
Source0:    http://ftp.gnu.org/gnu/aspell/aspell-0.60.6.1.tar.gz
Source1:    ftp://ftp.gnu.org/gnu/aspell/aspell-0.60.6.1.tar.gz
Source2:    ftp://ftp.gnu.org/gnu/aspell/dict
URL:        http://ftp.gnu.org/gnu/aspell
%description
 The Aspell package contains an interactive spell checking program and the Aspell libraries. Aspell can either be used as a library or as an independent spell checker. 
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
./configure --prefix=/usr &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin/
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/aspell-0.60.6.1/aspell-dev.html
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/aspell-0.60.6.1/aspell.html
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/aspell-0.60.6.1
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/aspell-0.60.6.1/aspell{,-dev}.html &&

install -v -m644 manual/aspell.html/* ${RPM_BUILD_ROOT}/usr/share/doc/aspell-0.60.6.1/aspell.html &&

install -v -m644 manual/aspell-dev.html/* ${RPM_BUILD_ROOT}/usr/share/doc/aspell-0.60.6.1/aspell-dev.html

install -v -m 755 scripts/ispell ${RPM_BUILD_ROOT}/usr/bin/

install -v -m 755 scripts/spell ${RPM_BUILD_ROOT}/usr/bin/

./configure &&
make
make install DESTDIR=${RPM_BUILD_ROOT} 


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