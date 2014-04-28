%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Tcl package contains the Tool Command Language, a robust general-purpose scripting language. 
Name:       tcl
Version:    8.6.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://prdownloads.sourceforge.net/tcl/tcl8.6.0-src.tar.gz

URL:        http://prdownloads.sourceforge.net/tcl
%description
 The Tcl package contains the Tool Command Language, a robust general-purpose scripting language. 
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
tar -xf  %_sourcedir/tcl8.6.0-html.tar.gz --strip-components=1
cd unix 
./configure --prefix=/usr --without-tzdata --mandir=/usr/share/man $([ $(uname -m) = x86_64 ] && echo --enable-64bit) 
make %{?_smp_mflags} 

sed -e "s@^\(TCL_SRC_DIR='\).*@\1/usr/include'@" -e "/TCL_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" -i tclConfig.sh

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd unix 

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make install  DESTDIR=${RPM_BUILD_ROOT} 

make install-private-headers  DESTDIR=${RPM_BUILD_ROOT} 

ln -v -sf tclsh8.6 ${RPM_BUILD_ROOT}/usr/bin/tclsh 

mkdir -pv -p ${RPM_BUILD_ROOT}/usr/share/doc/tcl-8.6.0 

cp -v -r  ../html/* ${RPM_BUILD_ROOT}/usr/share/doc/tcl-8.6.0


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chmod -v 755 /usr/lib/libtcl8.6.so
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog