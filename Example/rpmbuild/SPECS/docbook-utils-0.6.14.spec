%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     The DocBook-utils package is a collection of utility scripts used to convert and analyze SGML documents in general, and DocBook files in particular. The scripts are used to convert from DocBook or other SGML formats into “classical” file formats like HTML, man, info, RTF and many more. There's also a utility to compare two SGML files and only display the differences in markup. This is useful for comparing documents prepared for different languages. 
Name:       docbook-utils
Version:    0.6.14
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools
Requires:  openjade
Requires:  docbook-dsssl
Requires:  docbook
Source0:    ftp://sources.redhat.com/pub/docbook-tools/new-trials/SOURCES/docbook-utils-0.6.14.tar.gz
Source1:    http://www.linuxfromscratch.org/patches/blfs/7.5/docbook-utils-0.6.14-grep_fix-1.patch
URL:        ftp://sources.redhat.com/pub/docbook-tools/new-trials/SOURCES
%description
 The DocBook-utils package is a collection of utility scripts used to convert and analyze SGML documents in general, and DocBook files in particular. The scripts are used to convert from DocBook or other SGML formats into “classical” file formats like HTML, man, info, RTF and many more. There's also a utility to compare two SGML files and only display the differences in markup. This is useful for comparing documents prepared for different languages. 
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
patch -Np1 -i %_sourcedir/docbook-utils-0.6.14-grep_fix-1.patch &&
sed -i 's:/html::' doc/HTML/Makefile.in                &&
./configure --prefix=/usr --mandir=/usr/share/man      &&
make %{?_smp_mflags} 

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/bin
make docdir=${RPM_BUILD_ROOT}/usr/share/doc install DESTDIR=${RPM_BUILD_ROOT} 

for doctype in html ps dvi man pdf rtf tex texi txt
do
    ln -svf docbook2$doctype ${RPM_BUILD_ROOT}/usr/bin/db2$doctype

done

[ -d ${RPM_BUILD_ROOT}%{_infodir} ] && rm -f ${RPM_BUILD_ROOT}%{_infodir}/dir
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