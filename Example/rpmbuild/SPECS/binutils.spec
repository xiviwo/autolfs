%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Binutils package contains a linker, an assembler, and other tools for handling object files. 
Name:       binutils
Version:    1.0
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/binutils/binutils-2.23.2.tar.bz2

URL:        http://ftp.gnu.org/gnu/binutils
%description
 The Binutils package contains a linker, an assembler, and other tools for handling object files. 
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
sed -i -e 's/@colophon/@@colophon/' \
       -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
mkdir -pv ../binutils-build
cd ../binutils-build
CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../binutils-2.23.2/configure   \
    --prefix=/tools            \
    --disable-nls              \
    --with-lib-path=/tools/lib \
    --with-sysroot
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd ../binutils-build

mkdir -pv $RPM_BUILD_ROOT/tools/bin
make install DESTDIR=$RPM_BUILD_ROOT 

make -C ld clean
make -C ld LIB_PATH=${RPM_BUILD_ROOT}/usr/lib:/lib
cp -v ld/ld-new ${RPM_BUILD_ROOT}/tools/bin


[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
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