%define dist LFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Tar package contains an archiving program. 
Name:       tar
Version:    1.26
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/tar/tar-1.26.tar.bz2

URL:        http://ftp.gnu.org/gnu/tar
%description
 The Tar package contains an archiving program. 
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
patch -Np1 -i %_sourcedir/tar-1.26-manpage-1.patch
sed -i -e '/gets is a/d' gnu/stdio.in.h
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin \
            --libexecdir=/usr/sbin
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv $RPM_BUILD_ROOT/usr/share/man/man1
make install DESTDIR=$RPM_BUILD_ROOT 

make -C doc install-html docdir=/usr/share/doc/tar-1.26 DESTDIR=$RPM_BUILD_ROOT 

perl tarman > ${RPM_BUILD_ROOT}/usr/share/man/man1/tar.1


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