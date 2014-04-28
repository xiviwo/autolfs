%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The Wget package contains a utility useful for non-interactive downloading of files from the Web. 
Name:       wget
Version:    1.14
Release:    %{?dist}7.4
License:    GPLv3+
Group:      Development/Tools
Requires:  openssl
Source0:    http://ftp.gnu.org/gnu/wget/wget-1.14.tar.xz
Source1:    ftp://ftp.gnu.org/gnu/wget/wget-1.14.tar.xz
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/wget-1.14-texi2pod-1.patch
URL:        http://ftp.gnu.org/gnu/wget
%description
 The Wget package contains a utility useful for non-interactive downloading of files from the Web. 
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
patch -Np1 -i %_sourcedir/wget-1.14-texi2pod-1.patch 
./configure --prefix=/usr --sysconfdir=/etc --with-ssl=openssl 
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/etc
make install DESTDIR=${RPM_BUILD_ROOT} 


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
echo ca-directory=/etc/ssl/certs >> /etc/wgetrc
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog