%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The LLVM package contains a collection of modular and reusable compiler and toolchain technologies. The Low Level Virtual Machine (LLVM) Core libraries provide a modern source and target-independent optimizer, along with code generation support for many popular CPUs (as well as some less common ones!). These libraries are built around a well specified code representation known as the LLVM intermediate representation ("LLVM IR"). 
Name:       llvm
Version:    3.4
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  libffi
Requires:  python
Source0:    http://llvm.org/releases/3.4/llvm-3.4.src.tar.gz
Source1:    http://llvm.org/releases/3.4/clang-3.4.src.tar.gz
Source2:    http://llvm.org/releases/3.4/compiler-rt-3.4.src.tar.gz
URL:        http://llvm.org/releases/3.4
%description
 The LLVM package contains a collection of modular and reusable compiler and toolchain technologies. The Low Level Virtual Machine (LLVM) Core libraries provide a modern source and target-independent optimizer, along with code generation support for many popular CPUs (as well as some less common ones!). These libraries are built around a well specified code representation known as the LLVM intermediate representation ("LLVM IR"). 
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
tar -xf  %_sourcedir/clang-3.4.src.tar.gz -C tools &&
tar -xf  %_sourcedir/compiler-rt-3.4.src.tar.gz -C projects &&
mv tools/clang-3.4 tools/clang &&
mv projects/compiler-rt-3.4 projects/compiler-rt
sed -e 's:\$(PROJ_prefix)/docs/llvm:$(PROJ_prefix)/share/doc/llvm-3.4:' -i Makefile.config.in &&
CC=gcc CXX=g++ ./configure --prefix=/usr --sysconfdir=/etc --enable-libffi --enable-optimized --enable-shared --disable-assertions       &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/clang-analyzer/scan-build
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin/
mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/clang-analyzer/
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/clang-analyzer/scan-build/
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/man/man1/
mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/clang-analyzer
make install && DESTDIR=${RPM_BUILD_ROOT} 

for file in ${RPM_BUILD_ROOT}/usr/lib/lib{clang,LLVM,LTO}*.a

do
  test -f $file && chmod -v 644 $file
done
install -v -dm755 ${RPM_BUILD_ROOT}/usr/lib/clang-analyzer &&

for prog in scan-build scan-view
do
  cp -rfv tools/clang/tools/$prog ${RPM_BUILD_ROOT}/usr/lib/clang-analyzer/

  ln -sfv ../lib/clang-analyzer/$prog/$prog ${RPM_BUILD_ROOT}/usr/bin/

done &&
ln -sfv /usr/bin/clang ${RPM_BUILD_ROOT}/usr/lib/clang-analyzer/scan-build/ &&

mv -v ${RPM_BUILD_ROOT}/usr/lib/clang-analyzer/scan-build/scan-build.1 ${RPM_BUILD_ROOT}/usr/share/man/man1/


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