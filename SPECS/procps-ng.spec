Name:           procps-ng
Version:	3.3.6
Release:        1%{?dist}
Summary:	The Procps-ng package contains programs for monitoring processes.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/procps-ng.html
Source0:        http://sourceforge.net/projects/procps-ng/files/Production/procps-ng-3.3.6.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Procps-ng package contains programs for monitoring processes.

%prep
%setup -q

%build


./configure --prefix=/usr                           \
            --exec-prefix=                          \
            --libdir=/usr/lib                       \
            --docdir=/usr/share/doc/procps-ng-3.3.6 \
            --disable-static                        \
            --disable-skill                         \
            --disable-kill
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/lib
mkdir -pv $RPM_BUILD_ROOT/usr/lib
mv -v $RPM_BUILD_ROOT/usr/lib/libprocps.so.* $RPM_BUILD_ROOT/lib

ln -sfv ../../lib/libprocps.so.1.1.0 $RPM_BUILD_ROOT/usr/lib/libprocps.so


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog