%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Binutils package contains a linker, an assembler, and other tools for handling object files. 
Name:       binutils
Version:    2.23.2
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
rm -fv etc/standards.info
sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in
sed -i -e 's/@colophon/@@colophon/' \
       -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
mkdir -pv ../binutils-build
cd ../binutils-build
../binutils-2.23.2/configure --prefix=/usr --enable-shared
make tooldir=/usr %{?_smp_mflags} 


%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd ../binutils-build

mkdir -pv $RPM_BUILD_ROOT/usr/include
make tooldir=/usr install DESTDIR=$RPM_BUILD_ROOT 

cp -v ../binutils-2.23.2/include/libiberty.h ${RPM_BUILD_ROOT}/usr/include


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