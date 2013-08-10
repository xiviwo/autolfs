Name:           coreutils
Version:	8.21
Release:        1%{?dist}
Summary:	The Coreutils package contains utilities for showing and setting          the basic system characteristics.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/coreutils.html
Source0:        http://ftp.gnu.org/gnu/coreutils/coreutils-8.21.tar.xz

Patch0:        coreutils-8.21-i18n-1.patch
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Coreutils package contains utilities for showing and setting          the basic system characteristics.

%prep
%setup -q
%patch0 -p1 

%build

FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr         \
            --libexecdir=/usr/lib \
            --enable-no-install-program=kill,uptime
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/etc
mkdir -pv $RPM_BUILD_ROOT/usr/share/man/man8
mkdir -pv $RPM_BUILD_ROOT/bin
mkdir -pv $RPM_BUILD_ROOT/usr/sbin

mv -v $RPM_BUILD_ROOT/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $RPM_BUILD_ROOT/bin

mv -v $RPM_BUILD_ROOT/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} $RPM_BUILD_ROOT/bin

mv -v $RPM_BUILD_ROOT/usr/bin/{rmdir,stty,sync,true,uname,test,[} $RPM_BUILD_ROOT/bin

mv -v $RPM_BUILD_ROOT/usr/bin/chroot $RPM_BUILD_ROOT/usr/sbin

mv -v $RPM_BUILD_ROOT/usr/share/man/man1/chroot.1 $RPM_BUILD_ROOT/usr/share/man/man8/chroot.8

sed -i s/\"1\"/\"8\"/1 $RPM_BUILD_ROOT/usr/share/man/man8/chroot.8
mv -v $RPM_BUILD_ROOT/usr/bin/{head,sleep,nice} $RPM_BUILD_ROOT/bin


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog
