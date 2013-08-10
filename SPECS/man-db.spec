Name:           man-db
Version:	2.6.3
Release:        1%{?dist}
Summary:	The Man-DB package contains programs for finding and viewing man          pages.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/man-db.html
Source0:        http://download.savannah.gnu.org/releases/man-db/man-db-2.6.3.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Man-DB package contains programs for finding and viewing man          pages.

%prep
%setup -q

%build

./configure --prefix=/usr                        \
            --libexecdir=/usr/lib                \
            --docdir=/usr/share/doc/man-db-2.6.3 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

