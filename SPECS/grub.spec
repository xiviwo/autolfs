Name:           grub
Version:	2.00
Release:        1%{?dist}
Summary:	The GRUB package contains the GRand Unified Bootloader.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/grub.html
Source0:        http://ftp.gnu.org/gnu/grub/grub-2.00.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The GRUB package contains the GRand Unified Bootloader.

%prep
%setup -q

%build

sed -i -e '/gets is a/d' grub-core/gnulib/stdio.in.h

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-grub-emu-usb \
            --disable-efiemu       \
            --disable-werror
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
