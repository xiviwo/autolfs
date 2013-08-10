Name:           gcc
Version:	4.7.2
Release:        1%{?dist}
Summary:	The GCC package contains the GNU compiler collection, which          includes the C and C++ compilers.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gcc.html
Source0:        http://ftp.gnu.org/gnu/gcc/gcc-4.7.2/gcc-4.7.2.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The GCC package contains the GNU compiler collection, which          includes the C and C++ compilers.

%prep
%setup -q

%build

sed -i 's/install_to_$(INSTALL_DEST) $RPM_BUILD_ROOT//' libiberty/Makefile.in

sed -i 's/BUILD_INFO=info/BUILD_INFO=/' gcc/configure

case `uname -m` in
  i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac

sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in
rm -rf ../gcc-build

mkdir -v ../gcc-build
cd ../gcc-build

../gcc-4.7.2/configure --prefix=/usr            \
                       --libexecdir=/usr/lib    \
                       --enable-shared          \
                       --enable-threads=posix   \
                       --enable-__cxa_atexit    \
                       --enable-clocale=gnu     \
                       --enable-languages=c,c++ \
                       --disable-multilib       \
                       --disable-bootstrap      \
                       --with-system-zlib
make %{?_smp_mflags}

%install
cd ../gcc-build
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/lib
mkdir -pv $RPM_BUILD_ROOT/usr/share/gdb/auto-load/usr
mkdir -pv $RPM_BUILD_ROOT/usr/bin
mkdir -pv $RPM_BUILD_ROOT/
ln -sv ../usr/bin/cpp $RPM_BUILD_ROOT/lib
ln -sv gcc $RPM_BUILD_ROOT/usr/bin/cc

mkdir -pv $RPM_BUILD_ROOT/usr/share/gdb/auto-load/usr/lib

mv -v $RPM_BUILD_ROOT/usr/lib/*gdb.py $RPM_BUILD_ROOT/usr/share/gdb/auto-load/usr/lib


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

