Name:           findutils
Version:	4.4.2
Release:        1%{?dist}
Summary:	The Findutils package contains programs to find files. These          programs are provided to recursively search through a directory          tree and to create, maintain, and search a database (often faster          than the recursive find, but unreliable if the database has not          been recently updated).

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/findutils.html
Source0:        http://ftp.gnu.org/gnu/findutils/findutils-4.4.2.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Findutils package contains programs to find files. These          programs are provided to recursively search through a directory          tree and to create, maintain, and search a database (often faster          than the recursive find, but unreliable if the database has not          been recently updated).

%prep
%setup -q

%build


./configure --prefix=/usr                   \
            --libexecdir=/usr/lib/findutils \
            --localstatedir=/var/lib/locate
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/bin
mv -v $RPM_BUILD_ROOT/usr/bin/find $RPM_BUILD_ROOT/bin
sed -i 's/find:=${BINDIR}/find:=\/bin/' $RPM_BUILD_ROOT/usr/bin/updatedb

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog

