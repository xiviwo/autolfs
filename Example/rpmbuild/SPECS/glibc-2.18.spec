%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Glibc package contains the main C library. This library provides the basic routines for allocating memory, searching directories, opening and closing files, reading and writing files, string handling, pattern matching, arithmetic, and so on. 
Name:       glibc
Version:    2.18
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/glibc/glibc-2.18.tar.xz

URL:        http://ftp.gnu.org/gnu/glibc
%description
 The Glibc package contains the main C library. This library provides the basic routines for allocating memory, searching directories, opening and closing files, reading and writing files, string handling, pattern matching, arithmetic, and so on. 
%pre
%prep
export XORG_PREFIX="/opt"
export XORG_CONFIG="--prefix=$XORG_PREFIX  --sysconfdir=/etc --localstatedir=/var --disable-static"
rm -rf %{srcdir}
mkdir -pv %{srcdir} || :
case %SOURCE0 in 
	*.zip)
	unzip -x %SOURCE0 -d %{srcdir}
	;;
	*tar)
	tar xf %SOURCE0 -C %{srcdir} 
	;;
	*)
	tar xf %SOURCE0 -C %{srcdir} --strip-components 1
	;;
esac

%build
cd %{srcdir}
sed -i -e 's/static __m128i/inline &/' sysdeps/x86_64/multiarch/strstr.c
mkdir -pv ../glibc-build
cd ../glibc-build
../glibc-2.18/configure    \
    --prefix=/usr          \
    --disable-profile      \
    --enable-kernel=2.6.32 \
    --libexecdir=/usr/lib/glibc   --with-selinux=no --with-audit=no
make %{?_smp_mflags} 
touch /etc/ld.so.conf

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}
cd ../glibc-build

mkdir -pv $RPM_BUILD_ROOT/etc
mkdir -pv $RPM_BUILD_ROOT/dev
mkdir -pv $RPM_BUILD_ROOT/etc/ld.so.conf.d
mkdir -pv $RPM_BUILD_ROOT/usr/lib/locale
mkdir -pv $RPM_BUILD_ROOT/usr/share/zoneinfo/Asia
mkdir -pv $RPM_BUILD_ROOT/usr/include/rpc
mkdir -pv $RPM_BUILD_ROOT/usr/include/rpcsvc
make install DESTDIR=$RPM_BUILD_ROOT 

cp -v ../glibc-2.18/sunrpc/rpc/*.h ${RPM_BUILD_ROOT}/usr/include/rpc

cp -v ../glibc-2.18/sunrpc/rpcsvc/*.h ${RPM_BUILD_ROOT}/usr/include/rpcsvc

cp -v ../glibc-2.18/nis/rpcsvc/*.h ${RPM_BUILD_ROOT}/usr/include/rpcsvc

mkdir -pv ${RPM_BUILD_ROOT}/usr/lib/locale

make localedata/install-locales DESTDIR=$RPM_BUILD_ROOT 

cat > ${RPM_BUILD_ROOT}/etc/nsswitch.conf << "EOF"

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
tar -xf  %_sourcedir/tzdata2013d.tar.gz
ZONEINFO=${RPM_BUILD_ROOT}/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew solar87 solar88 solar89 \
          systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}

    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}

    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done
cp -v zone.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO
cp -v --remove-destination ${RPM_BUILD_ROOT}/usr/share/zoneinfo/Asia/Shanghai \

    ${RPM_BUILD_ROOT}/etc/localtime

cat > ${RPM_BUILD_ROOT}/etc/ld.so.conf << "EOF"

# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF
mkdir -pv ${RPM_BUILD_ROOT}/etc/ld.so.conf.d


[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
cat >> /etc/ld.so.conf << "EOF"

# Add an include directory

include /etc/ld.so.conf.d/*.conf

EOF
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog