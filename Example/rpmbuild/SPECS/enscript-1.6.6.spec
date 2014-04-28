%define dist BLFS
%define srcdir %_builddir/%{name}-%{version} 
Summary:     Enscript converts ASCII text files to PostScript, HTML, RTF, ANSI and overstrikes. 
Name:       enscript
Version:    1.6.6
Release:    %{?dist}7.5
License:    GPLv3+
Group:      Development/Tools

Source0:    http://ftp.gnu.org/gnu/enscript/enscript-1.6.6.tar.gz
Source1:    ftp://mirror.ovh.net/gentoo-distfiles/distfiles/enscript-1.6.6.tar.gz
URL:        http://ftp.gnu.org/gnu/enscript
%description
 Enscript converts ASCII text files to PostScript, HTML, RTF, ANSI and overstrikes. 
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
./configure --prefix=/usr --sysconfdir=/etc/enscript --localstatedir=/var --with-media=Letter &&
make && %{?_smp_mflags} 

pushd docs &&
  makeinfo --plaintext -o enscript.txt enscript.texi &&
popd

%install
cd %{srcdir}
rm -rf ${RPM_BUILD_ROOT}

mkdir -pv ${RPM_BUILD_ROOT}/usr/share/doc
make install && DESTDIR=${RPM_BUILD_ROOT} 

install -v -m755 -d ${RPM_BUILD_ROOT}/usr/share/doc/enscript-1.6.6 &&

install -v -m644    README* *.txt docs/*.txt ${RPM_BUILD_ROOT}/usr/share/doc/enscript-1.6.6


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