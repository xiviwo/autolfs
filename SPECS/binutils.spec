Name:           binutils
Version:	2.23.1
Release:        1%{?dist}
Summary:	The Binutils package contains a linker, an assembler, and other          tools for handling object files.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/binutils.html
Source0:        http://ftp.gnu.org/gnu/binutils/binutils-2.23.1.tar.bz2

Patch0:        binutils-2.23.1-testsuite_fix-1.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Binutils package contains a linker, an assembler, and other          tools for handling object files.

%prep
%setup -q
%patch0 -p1 

%build

rm -fv etc/standards.info
sed -i.bak '/^INFO/s/standards.info $RPM_BUILD_ROOT//' etc/Makefile.in
rm -rf ../binutils-build

mkdir -v ../binutils-build
cd ../binutils-build

../binutils-2.23.1/configure --prefix=/usr --enable-shared
make tooldir=/usr %{?_smp_mflags}

%install
cd ../binutils-build
rm -rf $RPM_BUILD_ROOT
make tooldir=$RPM_BUILD_ROOT/usr install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr
cp -v ../binutils-2.23.1/include/libiberty.h $RPM_BUILD_ROOT/usr/include


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

