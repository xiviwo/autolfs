%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The GCC package contains GNU compilers. This package is useful for compiling programs written in C, C++, Fortran, Java, Objective C, Objective C++, Ada, and Go. You should ensure you actually need one of these additional compilers (C and C++ are installed in LFS) before you install them. Additionally, there are instructions in the BLFS book to install OpenJDK-1.7.0.40/IcedTea-2.4.1, which can be used instead of the Java provided by the GCC package. Many consider the Iced Tea version to be a more robust Java environment than the one provided by GCC. 
Name:       gcc
Version:    4.8.1
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  dejagnu
Requires:  zip
Requires:  unzip
Requires:  which
Source0:    http://ftp.gnu.org/gnu/gcc/gcc-4.8.1/gcc-4.8.1.tar.bz2

URL:        http://ftp.gnu.org/gnu/gcc/gcc-4.8.1
%description
 The GCC package contains GNU compilers. This package is useful for compiling programs written in C, C++, Fortran, Java, Objective C, Objective C++, Ada, and Go. You should ensure you actually need one of these additional compilers (C and C++ are installed in LFS) before you install them. Additionally, there are instructions in the BLFS book to install OpenJDK-1.7.0.40/IcedTea-2.4.1, which can be used instead of the Java provided by the GCC package. Many consider the Iced Tea version to be a more robust Java environment than the one provided by GCC. 
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
make ins-all prefix=/opt/gnat %{?_smp_mflags} 

PATH_HOLD=$PATH 
export PATH=/opt/gnat/bin:$PATH_HOLD
find /opt/gnat -name ld -exec mv -v {} {}.old \;
find /opt/gnat -name as -exec mv -v {} {}.old \;

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}//
mkdir -pv ${RPM_BUILD_ROOT}/lib
mkdir -pv ${RPM_BUILD_ROOT}/opt
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/gcc/*linux-gnu/4.8.1
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
sed -i 's/\(install.*:\) install-.*recursive/\1/' libffi/Makefile.in         
sed -i 's/\(install-data-am:\).*/\1/'             libffi/include/Makefile.in 
sed -i 's/install_to_$(INSTALL_DEST) ${RPM_BUILD_ROOT}//'          libiberty/Makefile.in      

sed -i 's@\./fixinc\.sh@-c true@'                 gcc/Makefile.in            
case `uname -m` in
      i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac 
mkdir -pv ../gcc-build 
cd    ../gcc-build 
../gcc-4.8.1/configure --prefix=${RPM_BUILD_ROOT}/usr --libdir=${RPM_BUILD_ROOT}/usr/lib --libexecdir=${RPM_BUILD_ROOT}/usr/lib --enable-shared --enable-threads=posix --enable-__cxa_atexit --disable-multilib --disable-bootstrap --disable-install-libiberty --with-system-zlib --enable-clocale=gnu --enable-lto --enable-languages=c,c++,fortran,ada,go,java,objc,obj-c++ 
make
ulimit -s 32768 
../gcc-4.8.1/contrib/test_summary
make install  DESTDIR=${RPM_BUILD_ROOT} 

ln -v -sf  %_sourcedir/usr/bin/cpp ${RPM_BUILD_ROOT}/lib 

ln -v -sf gcc ${RPM_BUILD_ROOT}/usr/bin/cc     

rm -rf ${RPM_BUILD_ROOT}/opt/gnat 

export PATH=$PATH_HOLD 
unset PATH_HOLD

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
chown -v -R root:root /usr/lib/gcc/*linux-gnu/4.8.1/include{,-fixed} /usr/lib/gcc/*linux-gnu/4.8.1/ada{lib,include}
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog