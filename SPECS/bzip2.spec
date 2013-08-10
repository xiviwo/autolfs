Name:           bzip2
Version:	1.0.6
Release:        1%{?dist}
Summary:	The Bzip2 package contains programs for compressing and          decompressing files. Compressing text files withbzip2yields a much better          compression percentage than with the traditionalgzip.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/bzip2.html
Source0:        http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz

Patch0:        bzip2-1.0.6-install_docs-1.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Bzip2 package contains programs for compressing and          decompressing files. Compressing text files withbzip2yields a much better          compression percentage than with the traditionalgzip.

%prep
%setup -q
%patch0 -p1 

%build

sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so


make clean %{?_smp_mflags}

make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make PREFIX=$RPM_BUILD_ROOT/usr install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/lib
mkdir -pv $RPM_BUILD_ROOT/usr/lib
mkdir -pv $RPM_BUILD_ROOT/bin
cp -v bzip2-shared $RPM_BUILD_ROOT/bin/bzip2

cp -av libbz2.so* $RPM_BUILD_ROOT/lib

ln -sv ../../lib/libbz2.so.1.0 $RPM_BUILD_ROOT/usr/lib/libbz2.so

rm -v $RPM_BUILD_ROOT/usr/bin/{bunzip2,bzcat,bzip2}

ln -sv bzip2 $RPM_BUILD_ROOT/bin/bunzip2

ln -sv bzip2 $RPM_BUILD_ROOT/bin/bzcat


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog
