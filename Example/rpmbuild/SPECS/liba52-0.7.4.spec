%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     liba52 is a free library for decoding ATSC A/52 (also known as AC-3) streams. The A/52 standard is used in a variety of applications, including digital television and DVD. 
Name:       liba52
Version:    0.7.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://liba52.sourceforge.net/files/a52dec-0.7.4.tar.gz
URL:        http://liba52.sourceforge.net/files
%description
 liba52 is a free library for decoding ATSC A/52 (also known as AC-3) streams. The A/52 standard is used in a variety of applications, including digital television and DVD. 
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
./configure --prefix=/usr --mandir=/usr/share/man --enable-shared --disable-static CFLAGS="-g -O2 $([ $(uname -m) = x86_64 ] && echo -fPIC)" &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/include
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc/liba52-0.7.4
make install && DESTDIR=${RPM_BUILD_ROOT} 

cp liba52/a52_internal.h ${RPM_BUILD_ROOT}/usr/include/a52dec &&

install -v -m644 -D doc/liba52.txt ${RPM_BUILD_ROOT}/usr/share/doc/liba52-0.7.4/liba52.txt


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