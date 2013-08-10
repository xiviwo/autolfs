Name:           zlib
Version:	1.2.7
Release:        1%{?dist}
Summary:	The Zlib package contains compression and decompression routines          used by some programs.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/zlib.html
Source0:        http://www.zlib.net/zlib-1.2.7.tar.bz2

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Zlib package contains compression and decompression routines          used by some programs.

%prep
%setup -q

%build

./configure --prefix=/usr
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/lib
mkdir -pv $RPM_BUILD_ROOT/usr/lib
mv -v $RPM_BUILD_ROOT/usr/lib/libz.so.* $RPM_BUILD_ROOT/lib

ln -sfv ../../lib/libz.so.1.2.7 $RPM_BUILD_ROOT/usr/lib/libz.so


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

