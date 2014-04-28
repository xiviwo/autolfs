%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Tk package contains a TCL GUI Toolkit. 
Name:       tk
Version:    8.6.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  tcl
Requires:  xorg-libraries
Source0:    http://downloads.sourceforge.net/tcl/tk8.6.0-src.tar.gz
URL:        http://downloads.sourceforge.net/tcl
%description
 The Tk package contains a TCL GUI Toolkit. 
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
cd unix 
./configure --prefix=/usr --mandir=/usr/share/man $([ $(uname -m) = x86_64 ] && echo --enable-64bit) 
make %{?_smp_mflags} 

sed -e "s@^\(TK_SRC_DIR='\).*@\1/usr/include'@" -e "/TK_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" -i tkConfig.sh

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd unix 

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make install  DESTDIR=${RPM_BUILD_ROOT} 

make install-private-headers  DESTDIR=${RPM_BUILD_ROOT} 

ln -v -sf wish8.6 ${RPM_BUILD_ROOT}/usr/bin/wish 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libtk8.6.so
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog