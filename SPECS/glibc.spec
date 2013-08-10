Name:           glibc
Version:	2.17
Release:        1%{?dist}
Summary:	The Glibc package contains the main C library. This library          provides the basic routines for allocating memory, searching          directories, opening and closing files, reading and writing files,          string handling, pattern matching, arithmetic, and so on.

Group:		Development/System
License:        GPL
URL:            http://www.linuxfromscratch.org/lfs/view/stable/chapter06/glibc.html
Source0:        http://ftp.gnu.org/gnu/glibc/glibc-2.17.tar.xz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description
The Glibc package contains the main C library. This library          provides the basic routines for allocating memory, searching          directories, opening and closing files, reading and writing files,          string handling, pattern matching, arithmetic, and so on.

%prep
%setup -q

%build
rm -rf ../glibc-build

mkdir -v ../glibc-build
cd ../glibc-build

../glibc-2.17/configure  \
    --prefix=/usr          \
    --disable-profile      \
    --enable-kernel=2.6.25 \
    --libexecdir=/usr/lib/glibc
make %{?_smp_mflags}

%install
cd ../glibc-build
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/usr/lib/locale
make localedata/install-locales DESTDIR=$RPM_BUILD_ROOT
mkdir -pv $RPM_BUILD_ROOT/etc/ld.so.conf.d
mkdir -pv $RPM_BUILD_ROOT/usr/include
mkdir -pv $RPM_BUILD_ROOT/etc
touch $RPM_BUILD_ROOT/etc/ld.so.conf
cp -v ../glibc-2.17/sunrpc/rpc/*.h $RPM_BUILD_ROOT/usr/include/rpc

cp -v ../glibc-2.17/sunrpc/rpcsvc/*.h $RPM_BUILD_ROOT/usr/include/rpcsvc

cp -v ../glibc-2.17/nis/rpcsvc/*.h $RPM_BUILD_ROOT/usr/include/rpcsvc


cat >> $RPM_BUILD_ROOT/etc/ld.so.conf << "EOF"

# Add an include directory

include /etc/ld.so.conf.d/*.conf

EOF


cat > $RPM_BUILD_ROOT/etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF
cat > $RPM_BUILD_ROOT/etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
/*

%changelog


