%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     AbiWord is a word processor which is useful for writing reports, letters and other formatted documents. 
Name:       abiword
Version:    3.0.0
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  boost
Requires:  fribidi
Requires:  goffice
Requires:  wv
Requires:  enchant
Source0:    http://www.abisource.com/downloads/abiword/3.0.0/source/abiword-3.0.0.tar.gz
Source1:    http://www.abisource.com/downloads/abiword/3.0.0/source/abiword-docs-3.0.0.tar.gz
Source2:    http://www.linuxfromscratch.org/patches/blfs/svn/abiword-3.0.0-libgcrypt_1_6_0-1.patch
URL:        http://www.abisource.com/downloads/abiword/3.0.0/source
%description
 AbiWord is a word processor which is useful for writing reports, letters and other formatted documents. 
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
patch -Np1 -i abiword-3.0.0-libgcrypt_1_6_0-1.patch &&
./configure --prefix=/usr                           &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/abiword-2.9/templates
mkdir -pv ${RPM_BUILD_ROOT}/usr/share/abiword-2.9
make install DESTDIR=${RPM_BUILD_ROOT} 

tar -xf  %_sourcedir/abiword-docs-3.0.0.tar.gz &&
cd abiword-docs-3.0.0                &&
./configure --prefix=${RPM_BUILD_ROOT}/usr            &&
make
make install DESTDIR=${RPM_BUILD_ROOT} 

ls ${RPM_BUILD_ROOT}/usr/share/abiword-2.9/templates


[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
%clean
rm -rf ${RPM_BUILD_ROOT}
rm -rf %{srcdir}
%post
/sbin/ldconfig
install -v -m750 -d ~/.AbiSuite/templates &&

install -v -m640    /usr/share/abiword-2.9/templates/normal.awt-<lang> ~/.AbiSuite/templates/normal.awt
/usr/bin/install-info %{_infodir}/*.info %{_infodir}/dir || :
%preun
%files
%defattr(-,root,root,-)
%doc
/*
%changelog