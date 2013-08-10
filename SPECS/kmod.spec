Name:           kmod
Version:	12
Release:        1%{?dist}
Summary:	The Kmod package contains libraries and utilities for loading          kernel modules

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/kmod.html
Source0:        http://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-12.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Kmod package contains libraries and utilities for loading          kernel modules

%prep
%setup -q

%build

./configure --prefix=/usr       \
            --bindir=/bin       \
            --libdir=/lib       \
            --sysconfdir=/etc   \
            --disable-manpages  \
            --with-xz           \
            --with-zlib
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make pkgconfigdir=$RPM_BUILD_ROOT/usr/lib/pkgconfig install DESTDIR=$RPM_BUILD_ROOT

mkdir -pv $RPM_BUILD_ROOT/sbin $RPM_BUILD_ROOT/bin

for target in depmod insmod modinfo modprobe rmmod; do
 
  ln -sv ../bin/kmod $RPM_BUILD_ROOT/sbin/$target

done

ln -sv kmod $RPM_BUILD_ROOT/bin/lsmod


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


