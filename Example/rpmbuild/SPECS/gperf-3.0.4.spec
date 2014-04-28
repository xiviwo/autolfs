%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Gperf generates a perfect hash function from a key set. 
Name:       gperf
Version:    3.0.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/gperf/gperf-3.0.4.tar.gz
Source1:    ftp://ftp.gnu.org/gnu/gperf/gperf-3.0.4.tar.gz
URL:        http://ftp.gnu.org/gnu/gperf
%description
 Gperf generates a perfect hash function from a key set. 
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
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.0.4 &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/info
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/gperf-3.0.4
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -m644 -v doc/gperf.{dvi,ps,pdf} ${RPM_BUILD_ROOT}/usr/share/doc/gperf-3.0.4 &&

pushd ${RPM_BUILD_ROOT}/usr/share/info &&

  rm -v dir &&
  for FILENAME in *; do
    install-info $FILENAME dir 2>/dev/null

  done &&
popd

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