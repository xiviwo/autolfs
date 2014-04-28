%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GCC package contains the GNU compiler collection, which includes the C and C++ compilers. 
Name:       gcc
Version:    4.8.2
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2

URL:        http://ftp.gnu.org/gnu/gcc/gcc-4.8.2
%description
 The GCC package contains the GNU compiler collection, which includes the C and C++ compilers. 
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
case `uname -m` in
  i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac
sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in 
mv -v libmudflap/testsuite/libmudflap.c++/pass41-frag.cxx{,.disable}
mkdir -pv ../gcc-build
cd  %_sourcedir/gcc-build
SED=sed  %_sourcedir/gcc-4.8.2/configure --prefix=/usr --enable-shared --enable-threads=posix --enable-__cxa_atexit --enable-clocale=gnu --enable-languages=c,c++ --disable-multilib --disable-bootstrap --with-system-zlib
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd ../gcc-build

mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gdb/auto-load/usr/lib
make install DESTDIR=${RPM_BUILD_ROOT} 

ln -svf  %_sourcedir/usr/bin/cpp ${RPM_BUILD_ROOT}/lib

ln -svf gcc ${RPM_BUILD_ROOT}/usr/bin/cc

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/gdb/auto-load/usr/lib


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