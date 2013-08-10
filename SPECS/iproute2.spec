Name:           iproute2
Version:	3.8.0
Release:        1%{?dist}
Summary:	The IPRoute2 package contains programs for basic and advanced          IPV4-based networking.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/iproute2.html
Source0:        http://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-3.8.0.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The IPRoute2 package contains programs for basic and advanced          IPV4-based networking.

%prep
%setup -q

%build

sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile

sed -i 's/-Werror//' Makefile
make DESTDIR=$RPM_BUILD_ROOT %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make DESTDIR=$RPM_BUILD_ROOT             \
     MANDIR=$RPM_BUILD_ROOT/usr/share/man \
     DOCDIR=$RPM_BUILD_ROOT/usr/share/doc/iproute2-3.8.0 install

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


