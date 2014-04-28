%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Coreutils package contains utilities for showing and setting the basic system characteristics. 
Name:       coreutils
Version:    8.21
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/coreutils/coreutils-8.21.tar.xz

URL:        http://ftp.gnu.org/gnu/coreutils
%description
 The Coreutils package contains utilities for showing and setting the basic system characteristics. 
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
patch -Np1 -i %_sourcedir/coreutils-8.21-i18n-1.patch
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --libexecdir=/usr/lib    \
             --enable-no-install-program=kill,uptime   --disable-acl --without-selinux --disable-xattr
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv $RPM_BUILD_ROOT/bin
mkdir -pv $RPM_BUILD_ROOT/usr/bin/
mkdir -pv $RPM_BUILD_ROOT/usr/bin
mkdir -pv $RPM_BUILD_ROOT/usr/share/man/man8
mkdir -pv $RPM_BUILD_ROOT/usr/sbin
mkdir -pv $RPM_BUILD_ROOT/usr/share/man/man1
make install DESTDIR=$RPM_BUILD_ROOT 

mv -v ${RPM_BUILD_ROOT}/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} ${RPM_BUILD_ROOT}/bin

mv -v ${RPM_BUILD_ROOT}/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} ${RPM_BUILD_ROOT}/bin

mv -v ${RPM_BUILD_ROOT}/usr/bin/{rmdir,stty,sync,true,uname,test,[} ${RPM_BUILD_ROOT}/bin

mv -v ${RPM_BUILD_ROOT}/usr/bin/chroot ${RPM_BUILD_ROOT}/usr/sbin

mv -v ${RPM_BUILD_ROOT}/usr/share/man/man1/chroot.1 ${RPM_BUILD_ROOT}/usr/share/man/man8/chroot.8

sed -i s/\"1\"/\"8\"/1 ${RPM_BUILD_ROOT}/usr/share/man/man8/chroot.8

mv -v ${RPM_BUILD_ROOT}/usr/bin/{head,sleep,nice} ${RPM_BUILD_ROOT}/bin


[ -d $RPM_BUILD_ROOT%{_infodir} ] && rm -f $RPM_BUILD_ROOT%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog