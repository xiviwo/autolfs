Name:           groff
Version:	1.22.2
Release:        1%{?dist}
Summary:	The Groff package contains programs for processing and formatting          text.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/groff.html
Source0:        http://ftp.gnu.org/gnu/groff/groff-1.22.2.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Groff package contains programs for processing and formatting          text.

%prep
%setup -q

%build

PAGE=A4 ./configure --prefix=/usr

make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/share/doc/groff-1.22/pdf
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr/bin
ln -sv eqn $RPM_BUILD_ROOT/usr/bin/geqn

ln -sv tbl $RPM_BUILD_ROOT/usr/bin/gtbl


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog
